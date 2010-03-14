From: Guillaume Rousse <Guillaume.Rousse@inria.fr>
Subject: Re: unmount -l does not send unmount request to the server
Date: Sun, 14 Mar 2010 21:40:44 +0100
Message-ID: <4B9D49CC.8080603@inria.fr>
References: <4B530EFF.9000205@inria.fr>
	<7123090D-5BB9-4CF5-A024-56345DD8136F@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
	Linux NFSv4 mailing list <nfsv4@linux-nfs.org>
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <7123090D-5BB9-4CF5-A024-56345DD8136F@oracle.com>
List-Unsubscribe: <http://linux-nfs.org/cgi-bin/mailman/options/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=unsubscribe>
List-Archive: <http://linux-nfs.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@linux-nfs.org>
List-Help: <mailto:nfsv4-request@linux-nfs.org?subject=help>
List-Subscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=subscribe>
Sender: nfsv4-bounces@linux-nfs.org
Errors-To: nfsv4-bounces@linux-nfs.org
List-ID: <linux-nfs.vger.kernel.org>

Le 19/01/2010 17:37, Chuck Lever a =E9crit :
> As far as I understand it, "-l" means the kernel will do the local
> detach from the system's file name space whenever there are no more
> users (ie entirely asynchronously).  I don't think umount2(MNT_DETACH)
> indicates whether the kernel was able to completely unmount that file
> system by the time the call returns, so there's perhaps no way for
> umount.nfs to know whether it should send the UMNT request.  If the
> server is slow or unresponsive, that file system won't be unmounted
> until long after the umount.nfs command has exited.
> =

> This shouldn't be much of a big deal, since the server's rmtab is
> "ornamental" according to the man page.  No one should rely on it being
> accurate.
> =

> A possible way to fix this is to have the kernel send the UMNT.
It makes sense, but it doesn't seem to trigger much interest :)

Should I open a bug somewhere, to ensure the issue won't be forgotten ?
-- =

BOFH excuse #196:

Me no internet, only janitor, me just wax floors.
