From: YAMAMOTO Takashi <yamamoto@valinux.co.jp>
Subject: Re: [NFS client] NFS locks not released on abnormal process
 termination
Date: Thu, 08 Jan 2004 19:47:24 +0900
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1073558844.242410.4086.nullmailer@yamt.dyndns.org>
References: <87llpms8yr.fsf@ceramic.fifi.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Cc: trond.myklebust@fys.uio.no, theonetruekenny@yahoo.com,
	linux-kernel@vger.kernel.org, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.24)
	id 1AeXhY-00082F-9v
	for nfs@lists.sourceforge.net; Thu, 08 Jan 2004 02:47:44 -0800
Received: from fla1aak172.kng.mesh.ad.jp ([218.42.70.172] helo=yamt.dyndns.org)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.30)
	id 1AeXhX-0003GW-Rw
	for nfs@lists.sourceforge.net; Thu, 08 Jan 2004 02:47:44 -0800
To: phil@fifi.org
In-Reply-To: Your message of "09 Dec 2003 00:15:24 -0800"
	<87llpms8yr.fsf@ceramic.fifi.org>
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

hi,

> +	status = nlmclnt_proc(inode, cmd, fl);
> +	/* If we were signalled we still need to ensure that
> +	 * we clean up any state on the server. We therefore
> +	 * record the lock call as having succeeded in order to
> +	 * ensure that locks_remove_posix() cleans it out when
> +	 * the process exits.
> +	 */
> +	if (status == -EINTR || status == -ERESTARTSYS)
> +		posix_lock_file(filp, fl, 0);
> +	unlock_kernel();
> +	if (status < 0)
> +		return status;

i think it's problematic because you can't assume the lock was
granted on the server and the signaled process might not exit immediately.

YAMAMOTO Takashi



-------------------------------------------------------
This SF.net email is sponsored by: Perforce Software.
Perforce is the Fast Software Configuration Management System offering
advanced branching capabilities and atomic changes on 50+ platforms.
Free Eval! http://www.perforce.com/perforce/loadprog.html
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
