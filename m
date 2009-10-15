From: "NeilBrown" <neilb@suse.de>
Subject: Re: NFS4ERR_FILE_OPEN handling in Linux
Date: Fri, 16 Oct 2009 07:57:29 +1100
Message-ID: <ac125ee0f266d4c8563b504066865321.squirrel@neil.brown.name>
References: <19158.28240.964203.341327@notabene.brown>
	<1255611204.4317.19.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org
To: "Trond Myklebust" <Trond.Myklebust@netapp.com>
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <1255611204.4317.19.camel@heimdal.trondhjem.org>
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

On Thu, October 15, 2009 11:53 pm, Trond Myklebust wrote:
> On Thu, 2009-10-15 at 11:35 +1100, Neil Brown wrote:
>> Hi Trond,
>>
>>  Following up for a customer who had problem with NFSv4 when talking
>>  to a Solaris server with "nbman" enabled, I have questions about the
>>  handling of NFS4ERR_FILE_OPEN.
>>  In particular:
>>    1/ should commit c514983d8d2260020543a81589a2b8c7d4bdab4e be
>>       reverted, and
>>    2/ should nfs_errtbl map NFS4ERR_FILE_OPEN to -EBUSY rather than
>>       defaulting to -EIO
>>
>>  That commit, included below for reference, causes the NFS client to
>>  retry indefinitely if NFS4ERR_FILE_OPEN is returned.  This
>>  contradicts the comment which suggests it will only "retry a few
>>  times" and cannot be correct as a file could be held open (thus
>>  causing the error) indefinitely.
>
> I'm unfortunately unfamiliar with 'nbman' on Solaris. Could you please
> explain what it is, and why it should cause the nfs server to start
> returning NFS4ERR_FILE_OPEN?

I'm sorry, that should have been "nbmand" - my mistake.
'nbmand' is an abbreviation of "non-blocking mandatory locks".
It seems to be a ZFS option rather than an NFSv4 option and seems to
relate to providing better CIFS semantics on ZFS.  So it is
unsurprising that it causes and error message that, as you say, we
would normally expect only from an MS-windows server.

>
> As far as I know, the purpose of the NFS4ERR_FILE_OPEN error was to
> address the issue of MS Windows semantics, which do not allow certain
> operations (mainly unlink() and rename()) on an open file. Since the
> error is supposed to be transient (i.e. is caused by a lock) the current
> behaviour was chosen in order to try to provide posix-like semantics in
> these situations.
> While we could change the behaviour to return -EBUSY, that might
> conceivably break applications that expect to be able to create and
> destroy temporary files. I therefore think that some attempt should be
> made to wait and retry before we start returning application errors.

Given that this is a question of what a POSIX application can expect from
a non-POSIX filesystem, there can be no 'definitely right' answers.

A few retries could be justified I believe.  I don't think indefinite
retries is really justifiable.  So how many retries?
If we retries until exception->timeout exceeds HZ, that would be a max
delay of about 2 seconds, and about 5 retries.  Does that seem a
fair balance to you?

Maybe the below (untested and probably space-damaged, given for
illustration purposes only).

Thanks,
NeilBrown




diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index ed7c269..1cb6b0f 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -270,6 +270,11 @@ static int nfs4_handle_exception(const struct
nfs_server *server, int errorcode,
 			/* FALLTHROUGH */
 #endif /* !defined(CONFIG_NFS_V4_1) */
 		case -NFS4ERR_FILE_OPEN:
+			if (exception->timeout > HZ)
+				/* We have retried a decent amount, time to
+				 * fail
+				 */
+				break;
 		case -NFS4ERR_GRACE:
 		case -NFS4ERR_DELAY:
 			ret = nfs4_delay(server->client, &exception->timeout);
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 83ad47c..dcf5e03 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -5685,6 +5685,7 @@ static struct {
 	{ NFS4ERR_SYMLINK,	-ELOOP		},
 	{ NFS4ERR_OP_ILLEGAL,	-EOPNOTSUPP	},
 	{ NFS4ERR_DEADLOCK,	-EDEADLK	},
+	{ NFS4ERR_FILE_OPEN,	-EBUSY		},
 	{ NFS4ERR_WRONGSEC,	-EPERM		}, /* FIXME: this needs
 						    * to be handled by a
 						    * middle-layer.
