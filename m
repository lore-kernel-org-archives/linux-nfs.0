From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: NFS mount over IPv6 success
Date: Wed, 12 Nov 2008 11:50:53 -0500
Message-ID: <AA5165C1-1524-4720-A55E-99240BE7D1C9@oracle.com>
References: <20081109164132.GA19615@uio.no> <DBEFEF5C-00E2-4C4D-A9D4-81D24632DE34@oracle.com> <20081112133553.GA32294@uio.no> <491AFEB9.1090208@bull.net> <20081112163727.GA31625@uio.no>
Mime-Version: 1.0 (Apple Message framework v929.2)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: Le Rouzic <aime.le-rouzic@bull.net>, linux-nfs@vger.kernel.org
To: "Steinar H. Gunderson" <sgunderson-jG/AHqQBv7lBDgjK7y7TUQ@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet12.oracle.com ([148.87.113.124]:26722 "EHLO
	rgminet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753955AbYKLQvg (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 12 Nov 2008 11:51:36 -0500
In-Reply-To: <20081112163727.GA31625-6Z/AllhyZU4@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Nov 12, 2008, at 11:37 AM, Steinar H. Gunderson wrote:
> On Wed, Nov 12, 2008 at 05:05:13PM +0100, Le Rouzic wrote:
>> There is a prototype nfs-utils package based on nfs-utils-1.1.2 you  
>> can
>> play with at http://nfsv4.bullopensource.org/
>
> I already tried that with the latest git tree from Chuck, but no go
> (statd/nfsd didn't register on IPv6 in rpcbind, IIRC).

My nfs-utils doesn't have any of Bull's server-side changes.  It also  
doesn't have an IPv6-enabled rpc.statd yet.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
