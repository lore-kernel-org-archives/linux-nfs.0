From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: stale nfs file handle with exported loopback mounts
Date: Fri, 2 Nov 2007 15:23:17 -0400
Message-ID: <20071102192317.GF15595@fieldses.org>
References: <2062344196@web.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Neil Brown <neilb@suse.de>, NFS@lists.sourceforge.net
To: devzero@web.de
Return-path: <nfs-bounces@lists.sourceforge.net>
In-Reply-To: <2062344196@web.de>
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

On Fri, Nov 02, 2007 at 08:06:58PM +0100, devzero@web.de wrote:
> hi!
> 
> it seems i was having weird mail problems with sending mails trough my webmailer - at least two followups with attachments seem to be lost on sending and are not in my sent folder anymore....
> 
> anyway - here is a second try, but probably worse than what i have written before :)
> 
> 
> first off, thanks for the patch Neil, things look _much_ better now and exporting loopback mounts now basiscally works again.
> nice to see that my posting helped finding bugs.
> 
> maybe i have two more bugs for you :)
> 
> i have loopback mounts on the server and exported the parent dir with crossmnt option.
> 
> after mounting for the first time on the client, i`m getting "Invalid argument" for each loopback-mounted dir, if i do an ls -la on /mnt.
> this only happens _once_ and seems to be a server problem, because i can reboot the client and remount , i never see that errors again.

>From a quick look at the trace (thanks)--there's some getacl calls that
return EINVAL, then a few milliseconds later a second reply returns with
the original data.  That looks suspiciously like a reply being sent when
the request was also deferred pending the upcall to deal with the newly
encountered filesystem.  Sure enough, in
fs/nfs/nfs3acl.c:nfsd3_proc_getacl(), there's

	 if ((nfserr = fh_verify(rqstp, &resp->fh, 0, MAY_NOP)))
		RETURN_STATUS(nfserr_inval);

Change that nfserr_inval to an nfserr (here and in
fs/nfs/nfs2acl.c:nfsd_proc_getacl()), and maybe the problem will go
away.

--b.

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
