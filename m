From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH] export man page updated.
Date: Tue, 18 Sep 2007 11:48:52 -0400
Message-ID: <46EFF364.7040003@oracle.com>
References: <46EE9E73.1070002@RedHat.com> <46EEAF51.5010400@oracle.com>
	<46EFB157.4010508@RedHat.com>
Reply-To: chuck.lever@oracle.com
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------040202080206090303030306"
Cc: Linux NFS mailing list <nfs@lists.sourceforge.net>
To: Steve Dickson <SteveD@redhat.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IXfLa-00068E-S8
	for nfs@lists.sourceforge.net; Tue, 18 Sep 2007 08:50:46 -0700
Received: from rgminet01.oracle.com ([148.87.113.118])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IXfLe-0004m6-Bn
	for nfs@lists.sourceforge.net; Tue, 18 Sep 2007 08:50:51 -0700
In-Reply-To: <46EFB157.4010508@RedHat.com>
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
--------------040202080206090303030306
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Steve Dickson wrote:
> Chuck Lever wrote:
>> Steve Dickson wrote:
>>> It was pointed that the exportfs man page talks about
>>> the wrong file. In 2.6 kernels the export information
>>> is now kept in /var/lib/nfs/etab not /var/lib/nfs/xtab.
>>>
>>> This patch basically does a 's/xtab/etab' and is relative
>>> to the to the Fedora git tree
>>>
>>> git://git.infradead.org/~steved/nfs-utils.fedora
>>
>> Hrm, an attachment.
> hmm... are you not seeing the attachments inlined?

When I reply the attachment is discarded so I have to do a number of 
steps to quote your patch that wouldn't be necessary if you had inlined 
the patch.  The point of inlining patches rather than attaching them is 
to allow others to quote the patch in their reply with no extra steps. 
And there are tools to import inlined patches -- not sure if they work 
for attachments.

It's a scalability thing when reviewers have to deal with dozens of 
patches a day.

>> @@ -93,8 +93,8 @@ file, so that only default options and options given 
>> on the command
>>  line are used.
>>  .TP
>>  .B -r
>> -Reexport all directories. It synchronizes /var/lib/nfs/xtab
>> -with /etc/exports. It removes entries in /var/lib/nfs/xtab
>> +Reexport all directories. It synchronizes /var/lib/nfs/etab
>> +with /etc/exports. It removes entries in /var/lib/nfs/etab
>>  which are deleted from /etc/exports, and remove any entries from the
>>  kernel export table which are no longer valid.
>>  .TP
>>
>> In this hunk, why isn't the file name bold, like the others?
> Thats the way it was. If its a problem, I'll respin the patch...

See http://www.faqs.org/docs/Linux-mini/Man-Page.html#Q8

"Filenames are always in italics."

I ask "why isn't this filename bold" because the other instances in this 
particular man page are also bold and not italicized...  which is 
marginally incorrect, if not unconventional.

It's hard to say something like this is "a problem" since it is only a 
man page.  But I like to leave things a little cleaner (more correct) 
than when I found them.

--------------040202080206090303030306
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


--------------040202080206090303030306
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
--------------040202080206090303030306
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--------------040202080206090303030306--
