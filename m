From: Steve French <smfltc@us.ibm.com>
Subject: Re: [PATCH] Fix incorrect assignment
Date: Thu, 25 Oct 2007 12:58:18 -0500
Message-ID: <4720D93A.1000300@us.ibm.com>
References: <20071024205736.GL29830@fieldses.org>
	<OF5B1D195B.8B37E3EE-ON8725737F.00547AB2-8625737F.0054CCF1@us.ibm.com>
	<20071025160319.GA31888@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Prasad P <pvp@us.ibm.com>, nfs@lists.sourceforge.net
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Il6wg-0000V3-Uc
	for nfs@lists.sourceforge.net; Thu, 25 Oct 2007 10:56:38 -0700
Received: from e1.ny.us.ibm.com ([32.97.182.141])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1Il6wj-00037C-38
	for nfs@lists.sourceforge.net; Thu, 25 Oct 2007 10:56:44 -0700
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e1.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l9PHsXmY005115
	for <nfs@lists.sourceforge.net>; Thu, 25 Oct 2007 13:54:33 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id
	l9PHsXIF136512
	for <nfs@lists.sourceforge.net>; Thu, 25 Oct 2007 13:54:33 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id
	l9PHsWtW004840
	for <nfs@lists.sourceforge.net>; Thu, 25 Oct 2007 13:54:32 -0400
In-Reply-To: <20071025160319.GA31888@fieldses.org>
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

J. Bruce Fields wrote:
> On Thu, Oct 25, 2007 at 10:26:14AM -0500, Prasad P wrote:
>   
>> nfs-bounces@lists.sourceforge.net wrote on 10/24/2007 03:57:36 PM:
>>     
>>> On Wed, Oct 24, 2007 at 03:14:32PM -0500, Prasad P wrote:
>>>       
>>>> Dereferenced pointer "dentry" without checking and assigned to inode
>>>> in the declaration.
>>>>         
>>> Seems reasonable, but: looking at nfsd_dispatch(), it appears that the
>>> encode function is never called in this case (since rq_vers == 2 and
>>> nfsacld_proc_getacl() would have returned an error if it couldn't find a
>>> dentry).  Am I missing something?  Do you have a test case?
>>>
>>> --b.
>>>       
>> No, I don't have a test case.  This error was found by coverity scan.
>>
>> After declaration of the variables, we actually check the dentry and
>> dentry->d_inode, and if they are not NULL, assign dentry->d_inode to inode
>> variable.
>>
>> if (dentry == NULL || dentry->d_inode == NULL)
>>       return 0;
>> inode = dentry->d_inode;
>>     
>
> Yeah, the current code is obviously a little schizophrenic.  I'm just
> wondering whether we should fix it by deleting the early assignment or
> by removing the unnecessary checks.
>   

My preference would be the more intuitive and also safer answer (in the 
long term) ie to remove the early assignment.  It saves having to think 
as much in the long term about error conditions in the callers of this 
function.

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
