From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH/RFC] Return ENOSPC and EDQUOT for nfs
	writes	earlier.
Date: Fri, 13 Jul 2007 13:16:34 -0400
Message-ID: <4697B372.4080003@oracle.com>
References: <18069.29184.792156.782358@notabene.brown>
	<1184272296.30876.159.camel@heimdal.trondhjem.org>
Reply-To: chuck.lever@oracle.com
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------070708040102090105080506"
Cc: Neil Brown <neilb@suse.de>, nfs@lists.sourceforge.net
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1I9Ola-0006LM-CM
	for nfs@lists.sourceforge.net; Fri, 13 Jul 2007 10:17:18 -0700
Received: from rgminet01.oracle.com ([148.87.113.118])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1I9Old-00034e-6H
	for nfs@lists.sourceforge.net; Fri, 13 Jul 2007 10:17:22 -0700
In-Reply-To: <1184272296.30876.159.camel@heimdal.trondhjem.org>
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
--------------070708040102090105080506
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Trond Myklebust wrote:
> On Thu, 2007-07-12 at 10:12 +1000, Neil Brown wrote:
>> When a write to a local filesystem hits a space limitation such as
>> filesystem-full or quota-exhausted, the write fails synchronously.
>> You get ENOSPC or EDQUOT immediately.
>>
>> NFS cannot do that efficiently.
>>
>> Currently, you don't get these errors until 'fsync' or 'close'.  That
>> is very different from local filesystem behaviour, and is less than
>> ideal.
>>
>> The following patch causes these two errors to be returned through the
>> next write call once they are known about.
>>
>> A possible extension would be to set a flag when we first get such an
>> error, clear it when a write succeeds, and while the flag is set, do
>> all writes synchronously.  This would be even closer to
>> local-filesystem semantics, but I'm not sure it is worth it.
> 
> Well... I've been thinking along these last lines myself (i.e. forcing
> all subsequent writes to be synchronous whenever an error occurs).

OK, but...

After it is triggered by a write error, how would the synchronous 
behavior be turned off?  Both EDQUOT and ENOSPC, for example, are really 
a temporary error; if applications are smart enough, they can retry an 
EDQUOT and might get a successful write.  In that case, performance 
would be hosed until.... the client decides it's OK to use unstable 
writes again.

--------------070708040102090105080506
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


--------------070708040102090105080506
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
--------------070708040102090105080506
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--------------070708040102090105080506--
