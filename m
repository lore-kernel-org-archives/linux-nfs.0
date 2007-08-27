From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 1/9] mount.nfs: Fix nfs4mount_s prototype.
Date: Mon, 27 Aug 2007 19:58:20 -0400
Message-ID: <46D3651C.2000600@oracle.com>
References: <20070824171111.10418.69889.stgit@monet.1015granger.net>	<18127.22242.307898.761934@notabene.brown>	<46D30F84.302@oracle.com>
	<18131.15338.752272.415718@notabene.brown>
Reply-To: chuck.lever@oracle.com
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------060700000608040000020008"
Cc: nfs@lists.sourceforge.net
To: Neil Brown <neilb@suse.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IPoVO-0000WW-DW
	for nfs@lists.sourceforge.net; Mon, 27 Aug 2007 17:00:26 -0700
Received: from rgminet01.oracle.com ([148.87.113.118])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IPoVR-00044m-He
	for nfs@lists.sourceforge.net; Mon, 27 Aug 2007 17:00:31 -0700
In-Reply-To: <18131.15338.752272.415718@notabene.brown>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

This is a multi-part message in MIME format.
--------------060700000608040000020008
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Neil Brown wrote:
> Yes, I eventually worked this out.
> nfs4mount_s is firstly called with 'child' set to 0.  Then if that
> fails and that 'bg' option is set, we fork and call it again with
> 'child' set to 1.   So 'child' is more meaningful than 'bg'.
> 
> However that handling of 'bg' seems much more simple in nfsmount_s
> than in nfsmount - too simple?

nfsmount_s doesn't implement bg at all right now.  Those patches are 
still in my stack (and partly in my head).

> With 'fg', it should try some number of times.

It's supposed to retry until the retry=n timeout occurs (2 minutes) but 
experientially I'm not sure that's even implemented in the legacy 
mount.nfs.  I remember a bug we found when I was at NetApp where a fg 
mount tried the request just once and gave up.

> With 'bg', it should try once, then if that fails, fork and retry some
> number of times in that background.

Yes, it will retry based on an exponential back-off scheme, starting at 
one second and going up.  The limit is 30 seconds for the legacy 
mount.nfs, and I'm thinking of going up to 60 for the text-based 
implementation.

> Are you doing the 'retry' in the kernel?

No, we're considering that to be "policy" more or less, so it belongs in 
user space.  I'm going to make the kernel mount client fire one mount 
request that either succeeds or gives up.

> How do you tell it to only
> try once before you fork for 'bg'?

Each retry is driven from mount.nfs.

> Does the mount retry really need to be in the kernel?  I think that is
> a very different issue that just changing the option parsing to be
> string based.

This is one reason why this effort is a challenge.

> Also, I just noticed the:
>                     After a mount operation is backgrounded, all subsequent
>        mounts  on  the  same  NFS  server will be backgrounded immediately,
>        without first attempting  the  mount.
> 
> part of 'bg'.  That is awkward to implement when each individual mount
> is done in a separate processes as happens with mount.nfs.   There is
> code there which pretends to implement this, but of course it cannot
> work and should be stripped out.

That is correct.  Dick S. and I went over this on the list in the past 
week or two.  This is something that doesn't work at all in mount.nfs 
(in the legacy interface or in the text-based interface), but used to 
work in the util-linux mount command.

Peter S. has made the argument that we should more or less abandon all 
such "bg" kludges in favor of the automounter.

> I wonder if it is worth trying to record the host name in a file so
> that one instance can pass it to the next .... possibly not.  Though
> the kernel could easily know that a particular server is not
> responding, so the first mount attempt should give up quickly....

One thing that has been suggested is a mount server connection manager 
on the client.  Could be a kernel process... it would have a single 
connection per mountd, and all mount requests for that server would go 
down that connection.  The connection would time out after 5 minutes of 
inactivity.

In the case of multiple mounts to the same server, the mountd connection 
manager would know about the NFS server being down, and would be able to 
tell any mount requestors to retry later.

>>> And not making a matching change in nfsmount_s?
>> Upcoming patches will address this.
> 
> I notice that nfsmount and nfs4mount use 'running_bg'.  Not sure which
> is better, but it would be nice to be consistent. 

I hear you.  But the interfaces are going to be so different when all 
this is done, a little consistency is probably not going to be an issue. 
  I'll keep it in mind, though.

At some point we need to decide how much priority we're going to give to 
keeping the legacy parts of mount.nfs updated (ie just bug fixes -- 
certainly not new features like the "fscache" mount option).

--------------060700000608040000020008
Content-Type: text/x-vcard; charset=utf-8;
 name="chuck.lever.vcf"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="chuck.lever.vcf"

begin:vcard
fn:Chuck Lever
n:Lever;Chuck
org:Oracle Corporation;Corporate Architecture: Linux Projects Group
adr:;;1015 Granger Avenue;Ann Arbor;MI;48104;USA
title:Principal Member of Staff
tel;work:+1 248 614 5091
x-mozilla-html:FALSE
url:http://oss.oracle.com/~cel
version:2.1
end:vcard


--------------060700000608040000020008
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
--------------060700000608040000020008
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--------------060700000608040000020008--
