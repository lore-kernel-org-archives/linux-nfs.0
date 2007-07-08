From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: Status of mount.nfs
Date: Sun, 08 Jul 2007 19:16:03 -0400
Message-ID: <46917033.6040701@oracle.com>
References: <20070708191640.GA13962@uio.no>
Reply-To: chuck.lever@oracle.com
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------070005040006070906020304"
Cc: lamont@debian.org, nfs@lists.sourceforge.net
To: "Steinar H. Gunderson" <sesse@debian.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1I7g0M-0002zH-ND
	for nfs@lists.sourceforge.net; Sun, 08 Jul 2007 16:17:27 -0700
Received: from rgminet01.oracle.com ([148.87.113.118])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1I7g0P-0005uY-23
	for nfs@lists.sourceforge.net; Sun, 08 Jul 2007 16:17:30 -0700
In-Reply-To: <20070708191640.GA13962@uio.no>
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
--------------070005040006070906020304
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Steinar H. Gunderson wrote:
> Hi,
> 
> util-linux 2.13 drops support for NFS mounts:
> 
>   Release highlights:
>   ------------------
>    mount(8) doesn't include NFS client code anymore. Don't forget to
>    install nfs-utils 1.1.0 or newer with /sbin/[u]mount.{nfs,nfs4}.
> 
> However, the last I can find in nfs-utils changelog about this is:
> 
>   commit 99414bd3eecf93f23c378d3bb3d45bc98f364abc
>   Author: Neil Brown <neilb@suse.de>
>   Date:   Sat Jul 8 09:41:58 2006 +1000
>   
>       Disable building/installing mount.nfs by default.
>       
>       mount.nfs does not yet support 'user' option and some others.
>       To make it support this we need to make it setuid-root, and
>       some security isses need to be resolved before that can be done
>       safely.
> 
> What's the current recommendation for distributions with regard to NFS
> mounting?

Hmm, that's news!  :-(  Sounds like your only choice is to stay with 
older releases of util-linux in order to provide NFS support in the 
normal mount command binary.

I'm trying to build a prototype for in-kernel mount option string 
processing, and I thought mount.nfs would be the place to start.  I 
didn't realize that it was in such an "alpha" state.

However, as I've hacked on the code, I've come up with a number of fixes 
to some of the functional issues Neil mentions, although not the 
security ones.

I'll post here as soon as I can test them, since I think we want to get 
mount.nfs fixed and off the ground ASAP.  It's a good idea, although 
perhaps the current implementation still needs work.

--------------070005040006070906020304
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
email;internet:chuck dot lever at nospam oracle dot com
title:Principal Member of Staff
tel;work:+1 248 614 5091
x-mozilla-html:FALSE
version:2.1
end:vcard


--------------070005040006070906020304
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
--------------070005040006070906020304
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--------------070005040006070906020304--
