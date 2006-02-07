From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Broken nfs
Date: Mon, 06 Feb 2006 22:16:47 -0500
Message-ID: <1139282207.7877.25.camel@lade.trondhjem.org>
References: <Pine.GHP.4.63.0602061838200.2906@risc4.numis.northwestern.edu>
	 <1139281168.7877.18.camel@lade.trondhjem.org>
	 <Pine.GHP.4.63.0602062103500.3104@risc4.numis.northwestern.edu>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1F6JLo-0002w0-Nj
	for nfs@lists.sourceforge.net; Mon, 06 Feb 2006 19:17:08 -0800
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1F6JLn-0001pU-2J
	for nfs@lists.sourceforge.net; Mon, 06 Feb 2006 19:17:08 -0800
To: "L. D. Marks" <L-marks@northwestern.edu>
In-Reply-To: <Pine.GHP.4.63.0602062103500.3104@risc4.numis.northwestern.edu>
Sender: nfs-admin@lists.sourceforge.net
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

On Mon, 2006-02-06 at 21:07 -0600, L. D. Marks wrote:
> Thanks. Can you tell me which kernels it is fixed in? I guess I'll have to 
> find one which is somewhat compatible and hope it does not break the rocks 
> cluster installation.

I expect it to be fixed in 2.6.15-rc5 and newer kernels.

Cheers,
  Trond


> On Mon, 6 Feb 2006, Trond Myklebust wrote:
> 
> > On Mon, 2006-02-06 at 18:50 -0600, L. D. Marks wrote:
> >> I appear to have a broken nfs. With normal nfs mount of a directory (not
> >> automount, which appears to hide the problem)
> >> the script on the server:
> >>
> >> echo 10 > Probe
> >> ssh -x c0-0 cat Probe
> >> echo 11 > Probe
> >> ssh -x c0-0 cat Probe
> >>
> >> Will report 10 & 11 the first time, but afterwards 10 & 10. I attempted
> >> changing the attributes in the client
> >> /etc/fstab even using noac but this does not change anything. Any ideas
> >> welcome.
> >
> > Known issue on the client, that should be fixed in newer kernels.
> >
> > The exception is if the server is exporting something like an ext3,
> > reiser3, or msdos-based filesystem that don't support true change
> > attributes due to having limited mtime/ctime resolution. Then you will
> > always have the limitation that changes that occur within < 1 second of
> > one another may end up not bumping the mtime/ctime, in which case the
> > client may end up not detecting the change.
> >
> > Cheers,
> >  Trond
> >
> 
> Note: if you have an old email address for me, please note that "nwu" has
> been changed to "northwestern".
> -----------------------------------------------
> Laurence Marks
> Department of Materials Science and Engineering
> MSE Rm 2036 Cook Hall
> 2220 N Campus Drive
> Northwestern University
> Evanston, IL 60201, USA
> Tel: (847) 491-3996 Fax: (847) 491-7820
> email: L-marks at northwestern dot edu
> http://www.numis.northwestern.edu
> -----------------------------------------------
> 



-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=103432&bid=230486&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
