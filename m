From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Read/Write NFS I/O performance degraded by FLUSH_STABLE page  flushing
Date: Sat, 30 May 2009 08:43:31 -0400
Message-ID: <3DF33A10-E203-4914-88F2-8FDB4E31A3EE@fys.uio.no>
References: <OF3EBF546E.60A83A8F-ON852575A8.006EBB38-852575A8.006EFDE6@us.ibm.com> <5ECD2205-4DC9-41F1-AC5C-ADFA984745D3@oracle.com> <49FA0CE8.9090706@redhat.com> <1241126587.15476.62.camel@heimdal.trondhjem.org> <OF820C8732.74757E21-ON852575C5.0055C089-852575C5.00578071@us.ibm.com> <1243615595.7155.48.camel@heimdal.trondhjem.org> <OF0EEDB635.561D17D4-ON852575C5.005CBABA-852575C5.005FAD0D@us.ibm.com> <1243618500.7155.56.camel@heimdal.trondhjem.org> <ac442c870905291722x1ec811b2sda997d464898fcda@mail.gmail.com> <1243686363.5209.16.camel@heimdal.trondhjem.org>
Mime-Version: 1.0 (iPhone Mail 5H11)
Content-Type: text/plain;
	charset=us-ascii;
	format=flowed;
	delsp=yes
Cc: Greg Banks <gnb-xTcybq6BZ68@public.gmane.org>, Brian R Cowan <brcowan@us.ibm.com>,
	Chuck Lever <chuck.lever@oracle.com>,
	"linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
	"linux-nfs-owner@vger.kernel.org" <linux-nfs-owner@vger.kernel.org>,
	Peter Staubach <staubach@redhat.com>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out1.uio.no ([129.240.10.57]:44767 "EHLO mail-out1.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751815AbZE3Mnl (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 30 May 2009 08:43:41 -0400
In-Reply-To: <1243686363.5209.16.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On May 30, 2009, at 8:26, Trond Myklebust <trond.myklebust@fys.uio.no>  
wrote:
>
> Firstly, the server only uses O_SYNC if you turn off write gathering
> (a.k.a. the 'wdelay' option). The default behaviour for the Linux nfs
> server is to always try write gathering and hence no O_SYNC.
>
> Secondly, even if it were the case, then this does not justify  
> changing
> the client behaviour. The NFS protocol does not mandate, or even
> recommend that the server use O_SYNC. All it says is that a stable  
> write
> and an unstable write+commit should both have the same result: namely
> that the data+metadata must have been flushed to stable storage. The
> protocol spec leaves it as an exercise to the server implementer to do
> this as efficiently as possible.
>

Speaking of write gathering... Are we sure that heuristic that checks  
i_writecount isn't introducing spurious 10ms delays here? It seems odd  
for the server to do write gathering on nfsv3 writes: if the client  
wants to send more writes, it will set the unstable flag...

Trond
