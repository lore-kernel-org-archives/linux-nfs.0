From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: wonky autotools question
Date: Fri, 27 Jul 2007 16:17:04 -0400
Message-ID: <46AA52C0.8060209@oracle.com>
References: <46AA4BF6.6090002@oracle.com> <20070727200856.GI13965@fieldses.org>
Reply-To: chuck.lever@oracle.com
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------000307010908050302000307"
Cc: nfs@lists.sourceforge.net
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IEWGH-0007z2-Vm
	for nfs@lists.sourceforge.net; Fri, 27 Jul 2007 13:19:10 -0700
Received: from rgminet01.oracle.com ([148.87.113.118])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IEWGL-0000lE-GA
	for nfs@lists.sourceforge.net; Fri, 27 Jul 2007 13:18:13 -0700
In-Reply-To: <20070727200856.GI13965@fieldses.org>
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
--------------000307010908050302000307
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

J. Bruce Fields wrote:
> On Fri, Jul 27, 2007 at 03:48:06PM -0400, Chuck Lever wrote:
>> Hi all-
>>
>> It would be nice to enable more static code checking in nfs-utils (I'm 
>> especially interested in utils/mount/).  Is there a clean way to add 
>> additional CFLAGS, like -Wall, to utils/mount/Makefile using the autotools 
>> set up?  How about a lint or sparse target?
> 
> I don't know, sounds like a good idea.

So far, "CFLAGS=-Wall -O2 -g ./configure" enables full warnings 
everywhere in the tree, but I haven't found anything on how to specify 
additional CFLAGS in one subdir, and have it happen automatically.

> Last I checked, though, I thought there were still a fair number of
> warnings just with the current defaults.  Maybe we should fix those up
> first?

I'm focusing on utils/mount at the moment, and that seems pretty clean 
with the present C flags.  I have noticed warnings in other parts of the 
tree, but haven't had time to poke at them.

--------------000307010908050302000307
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
version:2.1
end:vcard


--------------000307010908050302000307
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
--------------000307010908050302000307
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--------------000307010908050302000307--
