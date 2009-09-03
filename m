Return-Path: <nfsv4-bounces@linux-nfs.org>
Message-ID: <4A9F6027.9050807@s3group.cz>
Date: Thu, 03 Sep 2009 08:20:23 +0200
From: Ondrej Valousek <webserv@s3group.cz>
To: Steve French <smfrench@gmail.com>
Subject: Re: POSIX ACL support for NFSV4 (using sideband protocol)
References: <524f69650909021156lf181c17uf800eba7c35a6f45@mail.gmail.com>	<20090902202206.GJ17884@fieldses.org>
	<524f69650909021353o1e055cbema16495c57cb9909b@mail.gmail.com>
In-Reply-To: <524f69650909021353o1e055cbema16495c57cb9909b@mail.gmail.com>
Cc: ffilzlnx@linux.vnet.ibm.com, linux-nfs@vger.kernel.org,
        nfsv4@linux-nfs.org, Trond Myklebust <Trond.Myklebust@netapp.com>,
        jra@samba.org, agruen@suse.de
List-Unsubscribe: <http://linux-nfs.org/cgi-bin/mailman/options/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=unsubscribe>
List-Archive: <http://linux-nfs.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@linux-nfs.org>
List-Help: <mailto:nfsv4-request@linux-nfs.org?subject=help>
List-Subscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=subscribe>
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Sender: nfsv4-bounces@linux-nfs.org
Errors-To: nfsv4-bounces@linux-nfs.org
MIME-Version: 1.0
List-ID: <linux-nfs.vger.kernel.org>


> 2) If POSIX->NFSv4 client mapping is done (as had been suggested IIRC
> by others in the past) at least you lose less data (NFSv4 ACLs are "richer"
> in function than POSIX ACLs - so at least with the POSIX->NFSv4->POSIX
> case you are limiting the user to the subset of choices which are actually
> going to be able to be stored, no inheritence etc.)
>
>   

I must say that I do not understand the motivation either. POSIX is not 
even a standard and should be replaced with NFSv4 acls.
Even now ext3/ext4 support NFSv4 acls (ok. patch is needed but the patch 
is there already).

If the decision was up to me, I would forbid any nfsv4 acls if the 
server can not store them properly (i.e. without any conversion) + 
forbid using nfsv4 with posix acls over sideband protocol (no standard, 
so netapp will never support this and the same is to be expected from 
Windows and Solaris). This is just adding mess and confusion.

My 5 cents...
Ondrej
_______________________________________________
NFSv4 mailing list
NFSv4@linux-nfs.org
http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4
