Return-Path: <nfsv4-bounces@linux-nfs.org>
Message-ID: <4A0A89BD.3030607@redhat.com>
Date: Wed, 13 May 2009 16:50:05 +0800
From: Eugene Teo <eugene@redhat.com>
To: Frank Filz <ffilzlnx.at.us.ibm.com@redhat.com>
Subject: Re: [PATCH] nfs: Fix NFS v4 client handling of MAY_EXEC in
	nfs_permission.
References: <1241837734.2404.4.camel@dyn9047022153>
In-Reply-To: <1241837734.2404.4.camel@dyn9047022153>
Cc: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org
List-Unsubscribe: <http://linux-nfs.org/cgi-bin/mailman/options/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=unsubscribe>
List-Archive: <http://linux-nfs.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@linux-nfs.org>
List-Help: <mailto:nfsv4-request@linux-nfs.org?subject=help>
List-Subscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=subscribe>
Content-Type: text/plain; charset="us-ascii"
Sender: nfsv4-bounces@linux-nfs.org
Errors-To: nfsv4-bounces@linux-nfs.org
MIME-Version: 1.0
List-ID: <linux-nfs.vger.kernel.org>

Frank Filz wrote:
> The problem is that permission checking is skipped if atomic open is
> possible, but when exec opens a file, it just opens it O_READONLY which
> means EXEC permission will not be checked at that time.
> 
> This problem is observed by the following sequence (executed as root):
> 
> mount -t nfs4 server:/ /mnt4
> echo "ls" >/mnt4/foo
> chmod 744 /mnt4/foo
> su guest -c "mnt4/foo"
> 
> Signed-off-by: Frank Filz <ffilzlnx at us.ibm.com>

Tested-by: Eugene Teo <eugeneteo@kernel.sg>

I have tested this on 2.6.29.3, and I can confirm that the patch fixed
the problem.

Btw, this looks like the same problem that was reported in 2006:
http://linux-nfs.org/pipermail/nfsv4/2006-November/005323.html
http://linux-nfs.org/pipermail/nfsv4/2006-November/005313.html
http://bugzilla.linux-nfs.org/show_bug.cgi?id=131

Thanks, Eugene
_______________________________________________
NFSv4 mailing list
NFSv4@linux-nfs.org
http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4
