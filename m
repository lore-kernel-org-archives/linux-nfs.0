From: Kumar Gala <galak@kernel.crashing.org>
Subject: Re: LTP ustat01 test fails on NFSROOT
Date: Mon, 29 Oct 2007 09:41:16 -0500
Message-ID: <45407DEE-37D0-437A-AF5F-17557D028E1A@kernel.crashing.org>
References: <CBDE987B-0713-4D62-8122-054183E75410@kernel.crashing.org>
	<1193188894.27073.20.camel@heimdal.trondhjem.org>
	<1954B8FA-6E29-4FB7-86B0-EA43AF8F2AAF@kernel.crashing.org>
	<2B2C1270-60FB-4830-A62C-D0357D2E1FB3@kernel.crashing.org>
	<1193335168.7705.39.camel@heimdal.trondhjem.org>
	<0CC518FE-47B0-4A32-B682-1CA5F7CBAC2F@kernel.crashing.org>
Mime-Version: 1.0 (Apple Message framework v752.2)
Content-Type: text/plain; charset="us-ascii"
Cc: neilb@suse.de, bfields@fieldses.org, nfs@lists.sourceforge.net,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1ImVmt-0005RB-UI
	for nfs@lists.sourceforge.net; Mon, 29 Oct 2007 07:40:20 -0700
Received: from gate.crashing.org ([63.228.1.57]
	ident=[U2FsdGVkX1/xjt7uTdsC696D2QTARojIyQknjmB3ZEk=])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1ImVmw-0003ny-8U
	for nfs@lists.sourceforge.net; Mon, 29 Oct 2007 07:40:24 -0700
In-Reply-To: <0CC518FE-47B0-4A32-B682-1CA5F7CBAC2F@kernel.crashing.org>
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


On Oct 26, 2007, at 4:42 AM, Kumar Gala wrote:

>
> On Oct 25, 2007, at 12:59 PM, Trond Myklebust wrote:
>
>> Could you please try the following patch?
>>
>> Cheers
>>   Trond
>> --------------------------------- CUT HERE  
>> -----------------------------
>> From: Trond Myklebust <Trond.Myklebust@netapp.com>
>> Date: Thu, 25 Oct 2007 13:56:10 -0400
>> NFS: Fix the ustat() regression
>>
>> Since 2.6.18, the superblock sb->s_root has been a dummy dentry  
>> with a
>> dummy inode. This breaks ustat(), which actually uses sb->s_root in a
>> vfstat() call.
>>
>> Fix this by making the s_root a dummy alias to the directory inode  
>> that was
>> used when creating the superblock.
>>
>> Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
>> ---
>>
>>  fs/nfs/getroot.c |   81 +++++++++++++++++ 
>> +------------------------------------
>>  1 files changed, 27 insertions(+), 54 deletions(-)
>
> Any reason not to send this to Linus as a bug fix for 2.6.24 (and  
> possibly stable)?

ping.  would love to see this is Linus's tree.

- k

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
