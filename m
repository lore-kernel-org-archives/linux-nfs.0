From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: Status of mount.nfs
Date: Mon, 09 Jul 2007 12:45:15 -0400
Message-ID: <4692661B.7080701@oracle.com>
References: <20070708191640.GA13962@uio.no>	<18065.43199.104020.412029@notabene.brown>
	<20070709095511.GA17815@uio.no>
Reply-To: chuck.lever@oracle.com
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------070100030604090900040407"
Cc: lamont@debian.org, nfs@lists.sourceforge.net
To: Neil Brown <neilb@suse.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1I7wNv-0005Gv-5p
	for nfs@lists.sourceforge.net; Mon, 09 Jul 2007 09:46:57 -0700
Received: from agminet01.oracle.com ([141.146.126.228])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1I7wNw-0006ug-3S
	for nfs@lists.sourceforge.net; Mon, 09 Jul 2007 09:46:54 -0700
In-Reply-To: <20070709095511.GA17815@uio.no>
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
--------------070100030604090900040407
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Steinar H. Gunderson wrote:
> On Mon, Jul 09, 2007 at 01:17:19PM +1000, Neil Brown wrote:
>> I wonder why you didn't find:
>> commit b3b111b1bd5fbc678419bf1964b6093045081139
>> Author: Neil Brown <neilb@suse.de>
>> Date:   Tue Mar 20 14:18:41 2007 +1100
>>
>>     Build mount.nfs by default, and install setuid
>>     
>>     Also fix a few bugs that came up in initial testing.
> 
> There's a simple explanation for that -- I checked the file ChangeLog, which
> doesn't seem to have been updated since September, now that I look at it. I
> guess you stopped updating it at some point...
> 
>> nfs-utils-1.1.0 builds and install mount.nfs by default, and should be
>> used with the new util-linux.

I just noticed this morning that "./configure --help" in the latest git 
repo still says this:

   --enable-mount          Create mount.nfs and don't use the util-linux
                           mount(8) functionality. [default=no]
                                                   ^^^^^^^^^^^^

If building and installing mount.nfs is the default, perhaps this should 
be updated.

--------------070100030604090900040407
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
url:http://oss.oracle.com/~cel/
version:2.1
end:vcard


--------------070100030604090900040407
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
--------------070100030604090900040407
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--------------070100030604090900040407--
