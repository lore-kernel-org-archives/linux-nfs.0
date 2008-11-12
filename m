From: "Steinar H. Gunderson" <sgunderson-jG/AHqQBv7lBDgjK7y7TUQ@public.gmane.org>
Subject: Re: NFS mount over IPv6 success
Date: Wed, 12 Nov 2008 17:53:45 +0100
Message-ID: <20081112165345.GA499@uio.no>
References: <20081109164132.GA19615@uio.no> <DBEFEF5C-00E2-4C4D-A9D4-81D24632DE34@oracle.com> <20081112133553.GA32294@uio.no> <491AFEB9.1090208@bull.net> <20081112163727.GA31625@uio.no> <AA5165C1-1524-4720-A55E-99240BE7D1C9@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Le Rouzic <aime.le-rouzic@bull.net>, linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from cassarossa.samfundet.no ([129.241.93.19]:51651 "EHLO
	cassarossa.samfundet.no" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751540AbYKLQxw (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 12 Nov 2008 11:53:52 -0500
In-Reply-To: <AA5165C1-1524-4720-A55E-99240BE7D1C9@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Nov 12, 2008 at 11:50:53AM -0500, Chuck Lever wrote:
>>> There is a prototype nfs-utils package based on nfs-utils-1.1.2 you  can
>>> play with at http://nfsv4.bullopensource.org/
>> I already tried that with the latest git tree from Chuck, but no go
>> (statd/nfsd didn't register on IPv6 in rpcbind, IIRC).
> My nfs-utils doesn't have any of Bull's server-side changes.  It also  
> doesn't have an IPv6-enabled rpc.statd yet.

I used Bull's nfs-utils -- the git tree I was referring to was your kernel
tree, not nfs-utils. :-)

Perhaps things would be better if I used Bull's kernel as well, but 2.6.27
has other issues for me, so it's hard to test on my machine.

/* Steinar */
-- 
Homepage: http://www.sesse.net/
