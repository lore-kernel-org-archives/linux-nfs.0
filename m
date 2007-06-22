From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: NFS debugging helpers
Date: Fri, 22 Jun 2007 12:39:57 -0400
Message-ID: <467BFB5D.3040003@oracle.com>
References: <467AE021.4000307@oracle.com> <20070621203748.GF4094@fieldses.org>
Reply-To: chuck.lever@oracle.com
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------000300090900090401000504"
Cc: Linux NFS Mailing List <nfs@lists.sourceforge.net>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1I1mBi-0007D6-Ew
	for nfs@lists.sourceforge.net; Fri, 22 Jun 2007 09:40:46 -0700
Received: from agminet01.oracle.com ([141.146.126.228])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1I1mBk-0006cY-JH
	for nfs@lists.sourceforge.net; Fri, 22 Jun 2007 09:40:49 -0700
In-Reply-To: <20070621203748.GF4094@fieldses.org>
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
--------------000300090900090401000504
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

J. Bruce Fields wrote:
> On Thu, Jun 21, 2007 at 04:31:29PM -0400, Chuck Lever wrote:
>> I thought I remembered that nfs-utils has simple programs to set NFS/RPC 
>> debugging flags, but I couldn't find them.
>>
>> So I constructed a couple of Python scripts to remember the flag names 
>> and values (see attached).  They are still a little raw.
>>
>> Is there anything like this already out there?
> 
> Try
> 
> 	man rpcdebug
> 
> It comes from nfs-utils/tools/rpcdebug/.

Ja, that's what I remembered.

Not necessarily to Bruce:  Is it actively maintained?  If a new 
debugging flag is added, is this tool updated by someone?

--------------000300090900090401000504
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


--------------000300090900090401000504
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
--------------000300090900090401000504
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--------------000300090900090401000504--
