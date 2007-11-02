From: devzero@web.de
Subject: Re: stale nfs file handle with exported loopback mounts
Date: Fri, 02 Nov 2007 20:37:12 +0100
Message-ID: <2062533683@web.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-15"
Cc: Neil Brown <neilb@suse.de>, NFS@lists.sourceforge.net
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
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

so, you mean this is a problem of the client or some "fix it at the client =
end" ?

that would be bad, since it would mean i need to touch all our linux system=
s which want to access our next-generation :) cd-rom server.... =


anyway =


> > > after mounting for the first time on the client, i`m getting "Invalid=
 argument" for each loopback-mounted dir, if i do an ls -la on /mnt.
> > > this only happens _once_ and seems to be a server problem, because i =
can reboot the client and remount , i never see that errors again.

wondering, why doesn`t it happen again, even if i reboot the client.....

regards
roland



> -----Urspr=FCngliche Nachricht-----
> Von: "J. Bruce Fields" <bfields@fieldses.org>
> Gesendet: 02.11.07 20:24:52
> An: devzero@web.de
> CC: Neil Brown <neilb@suse.de>, NFS@lists.sourceforge.net
> Betreff: Re: [NFS] stale nfs file handle with exported loopback mounts


> =

> On Fri, Nov 02, 2007 at 03:23:17PM -0400, J. Bruce Fields wrote:
> > On Fri, Nov 02, 2007 at 08:06:58PM +0100, devzero@web.de wrote:
> > > hi!
> > > =

> > > it seems i was having weird mail problems with sending mails trough m=
y webmailer - at least two followups with attachments seem to be lost on se=
nding and are not in my sent folder anymore....
> > > =

> > > anyway - here is a second try, but probably worse than what i have wr=
itten before :)
> > > =

> > > =

> > > first off, thanks for the patch Neil, things look _much_ better now a=
nd exporting loopback mounts now basiscally works again.
> > > nice to see that my posting helped finding bugs.
> > > =

> > > maybe i have two more bugs for you :)
> > > =

> > > i have loopback mounts on the server and exported the parent dir with=
 crossmnt option.
> > > =

> > > after mounting for the first time on the client, i`m getting "Invalid=
 argument" for each loopback-mounted dir, if i do an ls -la on /mnt.
> > > this only happens _once_ and seems to be a server problem, because i =
can reboot the client and remount , i never see that errors again.
> > =

> > >From a quick look at the trace (thanks)--there's some getacl calls that
> > return EINVAL, then a few milliseconds later a second reply returns with
> > the original data.  That looks suspiciously like a reply being sent when
> > the request was also deferred pending the upcall to deal with the newly
> > encountered filesystem.  Sure enough, in
> > fs/nfs/nfs3acl.c:nfsd3_proc_getacl(), there's
> > =

> > 	 if ((nfserr =3D fh_verify(rqstp, &resp->fh, 0, MAY_NOP)))
> > 		RETURN_STATUS(nfserr_inval);
> > =

> > Change that nfserr_inval to an nfserr (here and in
> > fs/nfs/nfs2acl.c:nfsd_proc_getacl()), and maybe the problem will go
> > away.
> =

> (I've been seeing some odd spurious replayed replies in the nfsv4 case
> as well, by the way--I suspect it's a similar problem, but haven't had
> the chance to track it down yet....)
> =

> --b.
> =



_____________________________________________________________________
Der WEB.DE SmartSurfer hilft bis zu 70% Ihrer Onlinekosten zu sparen!
http://smartsurfer.web.de/?mc=3D100071&distributionid=3D000000000066


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
