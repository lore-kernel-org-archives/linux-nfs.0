From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 02/23] mount.nfs: fix printf's normally
 hidden	behind NFS_MOUNT_DEBUG
Date: Mon, 30 Jul 2007 10:58:36 -0400
Message-ID: <46ADFC9C.8050503@oracle.com>
References: <20070728214918.21871.38740.stgit@localhost.localdomain>
	<46ADD039.9070405@RedHat.com>
Reply-To: chuck.lever@oracle.com
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------060106050305050009090704"
Cc: nfs@lists.sourceforge.net
To: Steve Dickson <SteveD@redhat.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IFWj2-0006d2-7H
	for nfs@lists.sourceforge.net; Mon, 30 Jul 2007 08:00:00 -0700
Received: from agminet01.oracle.com ([141.146.126.228])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IFWj4-0006RQ-RL
	for nfs@lists.sourceforge.net; Mon, 30 Jul 2007 08:00:04 -0700
In-Reply-To: <46ADD039.9070405@RedHat.com>
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
--------------060106050305050009090704
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Steve Dickson wrote:
> Chuck Lever wrote:
>> After I enabled NFS_MOUNT_DEBUG the compiler started spitting out 
>> warnings.
>> Fix up commas, output formatting, and double-wide character support.
> Aren't these debugging statements basically useless because one has to
> recompile to turn them on... Wouldn't it make more sense to add
> '-o mntdebug' flag so these could be turned on at will?

Useless for folks who don't want to or can't compile nfs-utils 
themselves, yes.  But I think the usefulness of these is for anyone who 
is developing mount.  They aren't for debugging problems mounting 
shares, but for debugging changes to mount itself.

I'm not opposed to making these debugging messages available dynamically 
(if we really believe they will be useful for everyday system 
administrators).... but....

Miklos has illuminated an important distinction between mount options 
that affect the behavior of the mounted file system, and mount options 
that control who can mount and how the mount takes place.  NFS is one of 
the worst offenders in mixing the two.

A "mntdebug" option would be of the latter type, and I'm beginning to 
think twice about the value of adding more of these.  I'm thinking about 
a way of specifying those types of options in some other way; for 
example, by using a separate NFS mount policy file like nsswitch.conf to 
set these up.  Just a random thought.

Or, rather, instead of "-o mntdebug" we might consider --mntdebug 
instead; that is, use a command line option instead of a mount option.

It's a nit, I know.

--------------060106050305050009090704
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


--------------060106050305050009090704
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
--------------060106050305050009090704
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--------------060106050305050009090704--
