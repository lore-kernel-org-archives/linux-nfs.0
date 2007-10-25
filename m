From: Kumar Gala <galak@kernel.crashing.org>
Subject: Re: LTP ustat01 test fails on NFSROOT
Date: Thu, 25 Oct 2007 14:05:05 -0500
Message-ID: <7E4866FF-74EE-410E-A5C4-334C7D5461DE@kernel.crashing.org>
References: <CBDE987B-0713-4D62-8122-054183E75410@kernel.crashing.org>
	<1193188894.27073.20.camel@heimdal.trondhjem.org>
	<1954B8FA-6E29-4FB7-86B0-EA43AF8F2AAF@kernel.crashing.org>
	<2B2C1270-60FB-4830-A62C-D0357D2E1FB3@kernel.crashing.org>
	<1193335168.7705.39.camel@heimdal.trondhjem.org>
	<6B3D0315-3441-45A1-A007-A193321B654A@kernel.crashing.org>
	<1193337589.7705.42.camel@heimdal.trondhjem.org>
Mime-Version: 1.0 (Apple Message framework v752.2)
Content-Type: text/plain; charset="us-ascii"
Cc: neilb@suse.de, bfields@fieldses.org, nfs@lists.sourceforge.net,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Il800-0007m9-DU
	for nfs@lists.sourceforge.net; Thu, 25 Oct 2007 12:04:08 -0700
Received: from gate.crashing.org ([63.228.1.57]
	ident=[U2FsdGVkX1+sL4C05lBLMxuAFrBoOBuoKzo9hIDNxxM=])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1Il804-0002RT-I0
	for nfs@lists.sourceforge.net; Thu, 25 Oct 2007 12:04:13 -0700
In-Reply-To: <1193337589.7705.42.camel@heimdal.trondhjem.org>
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


On Oct 25, 2007, at 1:39 PM, Trond Myklebust wrote:

>
> On Thu, 2007-10-25 at 13:36 -0500, Kumar Gala wrote:
>> On Oct 25, 2007, at 12:59 PM, Trond Myklebust wrote:
>>
>>> Could you please try the following patch?
>>
>> this fixes my issue.  Any reason this hasn't been accepted?
>
> Do you mean apart from the fact that I wrote it a couple of hours
> ago? :-)

Oh, sorry.  I glanced at the commit message and the 2.6.18 made me  
think its been around for a while.

- k

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
