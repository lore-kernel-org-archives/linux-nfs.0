From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [RFC,PATCH 4/14] knfsd: has_wspace per transport
Date: Wed, 23 May 2007 09:36:55 -0400
Message-ID: <46544377.4090604@oracle.com>
References: <20070523023206.GA14076@sgi.com>	<C27939D4.30F92%tom@opengridcomputing.com>
	<20070523064157.GE14076@sgi.com>
Reply-To: chuck.lever@oracle.com
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------020305040402010102040608"
Cc: "Talpey, Thomas" <Thomas.Talpey@netapp.com>,
	NeilBrown <neilb@suse.de>, Peter Leckie <pleckie@melbourne.sgi.com>,
	"J. Bruce Fields" <bfields@fieldses.org>,
	Linux NFS Mailing List <nfs@lists.sourceforge.net>
To: Greg Banks <gnb@sgi.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Hqr2c-0007l2-9E
	for nfs@lists.sourceforge.net; Wed, 23 May 2007 06:38:17 -0700
Received: from rgminet01.oracle.com ([148.87.113.118])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1Hqr2c-0002p5-Uk
	for nfs@lists.sourceforge.net; Wed, 23 May 2007 06:38:17 -0700
In-Reply-To: <20070523064157.GE14076@sgi.com>
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
--------------020305040402010102040608
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Greg Banks wrote:
> On Wed, May 23, 2007 at 12:22:44AM -0500, Tom Tucker wrote:
>>
>>
>> On 5/22/07 9:32 PM, "Greg Banks" <gnb@sgi.com> wrote:
>>
>>> On Tue, May 22, 2007 at 12:34:23PM -0500, Tom Tucker wrote:
>> I need to do a little clean up (e.g. atomic_inc()) and then I'll add them as
>> suggested. If there are dissenters, please speak now...
> 
> You should be able to get away with just ++.  They're only stats,
> it's not like you have logic depending on them being exact.

The usual way to do this is to allocate separate stat arrays for each 
CPU.  All the per-CPU arrays are summed only when something wants to 
display stat totals.

That way you can use ++, be fairly sure you will get accurate 
statistics, and not have to be concerned about CPU cache effects or lock 
contention.



--------------020305040402010102040608
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


--------------020305040402010102040608
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
--------------020305040402010102040608
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--------------020305040402010102040608--
