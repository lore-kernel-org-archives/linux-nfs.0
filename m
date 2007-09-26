From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 0/7] Add mount option parsing facility to
	text-based mount.nfs
Date: Wed, 26 Sep 2007 11:11:18 -0400
Message-ID: <46FA7696.3020705@oracle.com>
References: <20070925172637.4845.51938.stgit@monet.1015granger.net>
	<18169.44784.512106.346767@notabene.brown>
Reply-To: chuck.lever@oracle.com
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------020100040508050101060206"
Cc: nfs@lists.sourceforge.net
To: Neil Brown <neilb@suse.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IaYYN-0007MZ-8t
	for nfs@lists.sourceforge.net; Wed, 26 Sep 2007 08:11:55 -0700
Received: from rgminet01.oracle.com ([148.87.113.118])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IaYYP-0004cV-Qi
	for nfs@lists.sourceforge.net; Wed, 26 Sep 2007 08:12:00 -0700
In-Reply-To: <18169.44784.512106.346767@notabene.brown>
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
--------------020100040508050101060206
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Neil Brown wrote:
> On Tuesday September 25, chuck.lever@oracle.com wrote:
>> Hi Neil-
>>
>> Seven more patches for text-based mount.nfs.
>>
>> I found that it is necessary to do some rather advanced lexical parsing of
>> the mount option string in order to handle version/protocol fallback.  So I've
>> implemented a data structure that can handle the parsing requirements, and
>> some wrapper logic to convert the mount option string to the new data
>> structure and then convert it back to a string before calling mount(2).
>>
>> This series introduces the new facility and makes use of it for existing text-
>> based mount option processing (like adding "addr=" and so on).  In subsequent
>> patches I will make more use of the new facility.
> 
> Nice.
> 
> However: The current parsing of mount options (parse_opts,
> parse_options) allows for "quotes" around options so that an option
> can contain a comma (Gumble SELinux Grumble  context=foo,bar Grumble).
> Your mount option parsing doesn't allow for this.  Should it?

I thought it did, but I didn't test this explicitly.  It uses the same 
tokenization logic that legacy NFSv4 does, so I assumed quoting would 
work correctly.

Should I copy the ugly logic from nfsmount.c ?

(At this point, not sure the kernel option parser would support quoting 
either...)

--------------020100040508050101060206
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


--------------020100040508050101060206
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
--------------020100040508050101060206
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--------------020100040508050101060206--
