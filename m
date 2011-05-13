Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from e23smtp07.au.ibm.com ([202.81.31.140]:37921 "EHLO
	e23smtp07.au.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754049Ab1EMPk1 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 13 May 2011 11:40:27 -0400
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
To: =?utf-8?Q?Bj=C3=B6rn?= JACKE <bj@SerNet.DE>, "Ted Ts'o" <tytso@mit.edu>,
        sfrench@us.ibm.com, agruen@linbit.com, dilger.kernel@dilger.ca,
        sandeen@redhat.com, bfields@fieldses.org, jlayton@redhat.com,
        linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-ext4@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH -V5 00/24]  New ACL format for better NFSv4 acl interoperability
In-Reply-To: <E1QKJAl-00DGc7-EB@intern.SerNet.DE>
References: <1298469131-16555-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <20110228211145.GG28617@thunk.org> <E1QKJAl-00DGc7-EB@intern.SerNet.DE>
Date: Fri, 13 May 2011 21:10:09 +0530
Message-ID: <87zkmqobhi.fsf@linux.vnet.ibm.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, 12 May 2011 00:16:13 +0200, Björn JACKE <bj@SerNet.DE> wrote:
> Hi,
> 
> On 2011-02-28 at 16:11 -0500 Ted Ts'o sent off:
> > What is the current status of this patch series?  I seem to remember
> > that Christoph and Al Viro had some objections; have those been
> > cleared yet?  If not, can you summarize what their objections are?
> > 
> > To be honest I haven't been paying super close attention to this patch
> > series, and I'm curious what needs to happen with it one way or
> > another.
> 
> after the discussion of this path submission thread are there any major or
> minor issues left that prevent these to go upstream? I'd really love to see
> NFSv4 ACLs being available on Linux, too.
> 

I updated richaclv23 branch at 

http://git.kernel.org/?p=linux/kernel/git/kvaneesh/linux-richacl.git;a=summary

which is rebased against latest linus tree.  The changes pass richacl
test against local file system. I am yet to test richacl on NFS
client. Once i get the results i will repost the series again. 

-aneesh
