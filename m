From: "Chuck Lever" <chuck.lever@oracle.com>
Subject: Re: [PATCH] mount: enable retry for nfs23 to set the correct protocol for mount.
Date: Sat, 19 Jul 2008 12:09:00 -0400
Message-ID: <76bd70e30807190909n12b9f70an87ccb62198c3a7d@mail.gmail.com>
References: <18556.40594.897682.204554@notabene.brown>
	 <76bd70e30807150811p56feb02bo6e4a366d5577b398@mail.gmail.com>
	 <18559.53893.95829.499988@notabene.brown>
Reply-To: chucklever@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "Steve Dickson" <SteveD@redhat.com>, linux-nfs@vger.kernel.org
To: "Neil Brown" <neilb@suse.de>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.155]:28874 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753293AbYGSQJC (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 19 Jul 2008 12:09:02 -0400
Received: by fg-out-1718.google.com with SMTP id 19so334079fgg.17
        for <linux-nfs@vger.kernel.org>; Sat, 19 Jul 2008 09:09:00 -0700 (PDT)
In-Reply-To: <18559.53893.95829.499988-wvvUuzkyo1EYVZTmpyfIwg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Neil-

On Thu, Jul 17, 2008 at 7:15 PM, Neil Brown <neilb@suse.de> wrote:
> On Tuesday July 15, chuck.lever@oracle.com wrote:
>> On Tue, Jul 15, 2008 at 8:56 AM, Neil Brown <neilb@suse.de> wrote:
>> > This is the promised patch that adds mountproto=tcp to the string
>> > mount options if needed.
>> > We still get a 90second timeout, but at least it works rather than
>> > saying "mount.nfs: internal error".
>> >
>> > It seems to me that it would be best to avoid the first call to mount
>> > altogether.  Simply always do a probe_both and then do a mount based
>> > on the results of that.
>> > Is there a good reason not to?
>>
>> If I understand the question correctly, I think it doesn't because in
>> the most common cases, this isn't necessary.  The mount options are
>> usually adequate, and most servers support all the necessary NFS
>> versions and transport protocols.  This saves ephemeral ports and uses
>> less network traffic.
>
> Yes, I think you understand the question correctly.
>
> Your point about saving ephemeral ports is a strong one.
>
> The "most servers" point is less strong.  If there are any valid uses
> were the current code causes unnecessary delays we should try to
> address them, even if they are relatively few.

I think it's reasonable to look at the less common cases carefully to
see if we can improve things without making the common cases worse.

> Suppose we were to take this approach:
>
>   mount.nfs does DNS lookup and portmap look to find IP address and
>      port number.  However it *doesn't* send a 'clnt_ping' as
>      probe_port currently does.
>   The information it collects is explicitly given to the kernel with
>       mountproto= mountport= etc.
>   The kernel talks directly to mountd (given proto/addr/port) to get
>      the filehandle and so forth.  It doesn't talk to portmap at all
>      if it is given the required port numbers.
>
> This way there is no duplication of effort, but the "try this/try that"
> heuristics are all in user-space where they (arguably) belong and
> where it is easier to have control over timeouts.
>
> The only case where the above would not easily do the right thing is
> when portmap reports a port that the kernel cannot successfully talk
> to.  That is really a configuration error (rather than just an
> 'interesting' configuration).  In that case, mount.nfs could
> retry probe_both but this time do the clnt_ping to make sure the
> service really is there.
>
> Thoughts?

Using a connected UDP socket for both the kernel's rpcbind and it's
mountd client could help in many cases, including, probably, the one
you mention below, without the need for changing the current
architecture.

One thing about explicitly specifying mountport and mountproto during
a mount is that the umount.nfs command may have to include some logic
to throw those out and reprobe if those settings don't work at unmount
time.  These options were added to allow traversing a firewall using a
fixed port and protocol; overloading them for the case you describe
above may perhaps have some unpleasant consequences for the fixed
port/protocol case.

>> > If an NFS server is only listening on TCP for portmap (as apparently
>> > MS-Windows-Server2003R2SP2 does), mount doesn't cope.  There is retry
>> > logic in case the initial choice of version/etc doesn't work, but it
>> > doesn't cope with mountd needing tcp.

I think that is mostly because the text-based mount option rewriting
logic isn't robust yet.  I have several patches in the IPv6 series
that should address some of this.

But many of Linux's NFS auxiliary services are UDP-only.  statd and
sm-notify, for instance, are UDP-only as far as I can tell.  And
recently the kernel's NLM service was changed to listen only on TCP if
clients are connecting to servers only via TCP -- and that breaks some
local Linux services that assume UDP will always be there (like
SM_MON).

sm-notify, specifically, will be difficult to convert to use TCP as it
capitalizes on the use of a single unconnected UDP socket to send
portmap requests and reboot notifications to multiple hosts using only
a single port.

I think we have more problems with a TCP-only NFSv2/v3 server than
just the behavior of text-based mounts.

-- 
Chuck Lever
