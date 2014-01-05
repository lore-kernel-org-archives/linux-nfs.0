Return-Path: linux-nfs-owner@vger.kernel.org
Received: from userp1040.oracle.com ([156.151.31.81]:44269 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752090AbaAEXjG convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 5 Jan 2014 18:39:06 -0500
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 7.1 \(1827\))
Subject: Re: [RFC PATCH 1/5] sunrpc: don't wait for write before allowing reads from use-gss-proxy file
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20140106103036.1f7ebc5f@notabene.brown>
Date: Sun, 5 Jan 2014 18:38:40 -0500
Cc: "J.;Bruce Fields" <bfields@fieldses.org>, Jeff Layton <jlayton@redhat.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Simo Sorce <simo@redhat.com>
Message-Id: <B519510B-7574-4AF0-BFA7-FC1F464F5F49@oracle.com>
References: <1388579314-15255-1-git-send-email-jlayton@redhat.com> <1388579314-15255-2-git-send-email-jlayton@redhat.com> <20140102212149.GC28219@fieldses.org> <20140106093744.14fc3670@notabene.brown> <20140105225421.GA24059@fieldses.org> <20140106103036.1f7ebc5f@notabene.brown>
To: Neil Brown <neilb@suse.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Jan 5, 2014, at 6:30 PM, NeilBrown <neilb@suse.de> wrote:

> On Sun, 5 Jan 2014 17:54:21 -0500 "J. Bruce Fields" <bfields@fieldses.org>
> wrote:
> 
>> On Mon, Jan 06, 2014 at 09:37:44AM +1100, NeilBrown wrote:
>>> On Thu, 2 Jan 2014 16:21:50 -0500 "J. Bruce Fields" <bfields@fieldses.org>
>>> wrote:
>>> 
>>>> On Wed, Jan 01, 2014 at 07:28:30AM -0500, Jeff Layton wrote:
>>>>> It doesn't make much sense to make reads from this procfile hang. As
>>>>> far as I can tell, only gssproxy itself will open this file and it
>>>>> never reads from it. Change it to just give the present setting of
>>>>> sn->use_gss_proxy without waiting for anything.
>>>> 
>>>> I think my *only* reason for doing this was to give a simple way to wait
>>>> for gss-proxy to start (just wait for a read to return).
>>>> 
>>>> As long as gss-proxy has some way to say "I'm up and running", and as
>>>> long as that comes after writing to use-gss-proxy, we're fine.
>>>> 
>>> 
>>> 
>>> Only tangentially related to the above email .....
>>> 
>>> I had a look at this new-fangled gssproxy thing and while it mostly seems
>>> like a good idea, I find the hard-coding of "/var/run/gssproxy.sock" in the
>>> kernel source .... disturbing.
>>> You never know when some user-space might want to change that - maybe to
>>> "/run/gssproxy.sock" (unlikely I know - but possible).
>>> 
>>> Probably the easiest would be to hand the path to the kernel.
>>> 
>>> e.g. instead  of writing '1' to "use-gss-proxy", we could 
>>>  echo /my/path/gss-proxy-sock > /proc/net/rpc/use-gss-proxy
>>> 
>>> Then you could even use an 'abstract' socket name if you wanted. i.e. one
>>> starting with a nul and which doesn't exist anywhere in the filesystem.
>>> I would feel a lot more comfortable with that than with the current
>>> hard-coding.
>> 
>> See also RPCBIND_SOCK_PATHNAME.  (I *think* that's completely hardcoded,
>> not just a default.)
> 
> Arrgghhh!! (Hi Chuck.  Yes, I agree it is "undesirable in the long term").

I think that, when I added rpcbind AF_LOCAL support, we just didn't have a way for the kernel to find out what socket pathname had been chosen by user space.  But for gssproxy, we should think hard about the security ramifications of allowing user space to tell the kernel how to access its security helpers.

> 
>> 
>> I get the general principle.  I have a hard time seeing how it would be
>> a problem in practice.
> 
> One day some distro will decide that it is time to get rid of the legacy
> symlink (or bind mount) of /var/run -> /run.  And they will test it out and
> everything will work fine.  So they will commit to it.
> And then when they release it, their customers will discover that NFS doesn't
> work properly with gss (because the distro forgot to test that).

Right, but we're not at that point yet (or are we?).  Maybe we should wait until we get there, to avoid over-design.  Why would it be infeasible for such a distribution to find the hard-coded pathname in the kernel and simply change it and rebuild?

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




