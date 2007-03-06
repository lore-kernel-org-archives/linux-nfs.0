From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 000 of 2] A couple of possible nfs client patches
Date: Tue, 06 Mar 2007 09:57:44 -0500
Message-ID: <45ED8168.4050203@oracle.com>
References: <20070306163710.8128.patches@notabene>
Reply-To: chuck.lever@oracle.com
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------060503090900080403050108"
Cc: nfs@lists.sourceforge.net,
	Trond Myklebust <trond.myklebust@fys.uio.no>
To: NeilBrown <neilb@suse.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HOb8P-00068o-Oi
	for nfs@lists.sourceforge.net; Tue, 06 Mar 2007 06:59:26 -0800
Received: from agminet01.oracle.com ([141.146.126.228])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HOb8O-0004iw-HX
	for nfs@lists.sourceforge.net; Tue, 06 Mar 2007 06:59:28 -0800
In-Reply-To: <20070306163710.8128.patches@notabene>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

This is a multi-part message in MIME format.
--------------060503090900080403050108
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

NeilBrown wrote:
> Hi Trond,
>  I wonder if you would consider the following two patches.
> 
> The first fixes a real bug that is trivial to demonstrate: script
> below.  The problem is that the fattr which is extracted from
> READDIRPLUS results does not get a ->time_start set.  This can result
> is incorrect attributes being set on files.
> 
> The second is really a work-around for a deeper problem (invalidate_inode_pages2
> racing with do_no_page) but has value in itself I think.  It extents the combination
>  -o nolock,nocto
> to avoid flush and invalidate on locking requests.

This sounds like the behavior enabled by the 'llock' mount option on 
Solaris.  Is that your intent?

IMO it is a clever idea to enable 'llock' behavior on Linux with the 
combination of already existing mount options.

--------------060503090900080403050108
Content-Type: text/x-vcard; charset=utf-8;
 name="chuck.lever.vcf"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="chuck.lever.vcf"

begin:vcard
fn:Chuck Lever
n:Lever;Chuck
org:Oracle Corporation;Corporate Architecture Linux Projects Group
email;internet:chuck dot lever at nospam oracle dot com
title:Principal Member of Staff
tel;work:+1 248 614 5091
x-mozilla-html:FALSE
version:2.1
end:vcard


--------------060503090900080403050108
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
--------------060503090900080403050108
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--------------060503090900080403050108--
