From: mehta kiran <kiranmehta1981@yahoo.com>
Subject: Re: file :"/var/lib/nfs/rmtab"
Date: Thu, 3 Feb 2005 03:42:41 -0800 (PST)
Message-ID: <20050203114241.7498.qmail@web51610.mail.yahoo.com>
References: <42020B15.4030602@moving-picture.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CwfNo-0002tS-MU
	for nfs@lists.sourceforge.net; Thu, 03 Feb 2005 03:42:48 -0800
Received: from web51610.mail.yahoo.com ([206.190.38.215])
	by sc8-sf-mx2.sourceforge.net with smtp (Exim 4.41)
	id 1CwfNn-0005F1-4r
	for nfs@lists.sourceforge.net; Thu, 03 Feb 2005 03:42:48 -0800
To: James Pearson <james-p@moving-picture.com>
In-Reply-To: <42020B15.4030602@moving-picture.com>
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

Or is it for security reasons , so as to
prevent server from fake client handle.

--thanks,.
 --kiran

--- James Pearson <james-p@moving-picture.com> wrote:

> mehta kiran wrote:
> > Hi , 
> >        In mountd man page , it written that
> >        rmtab is ornamental and client can contiune
> >        to use filesystem even after calling umount
> >        for that filesystem.
> > 
> >        Is there any real use of this rmtab file ?
> >        Does mountd use this file to know the
> >        clients having access to filesystem ?
> >        If yes , isn,t filehandle supplied by 
> >        client enough to prove that client has
> access
> >        to filesystem. ?
> 
> On 2.4 kernels it is not 'ornamental' - if the
> server reboots without an 
> entry for a client mount in /var/lib/nfs/rmtab, then
> the client will get 
> a stale NFS file handle when the server reboots.
> This can happen if 
> umount fails e.g. the mount point is busy -
> rpc.mountd on the server 
> removes the entry from /var/lib/nfs/rmtab, but
> umount fails, so the file 
> system remains mounted.
> 
> I believe the situation has changed with 2.6.
> 
> James Pearson
> 


__________________________________________________
Do You Yahoo!?
Tired of spam?  Yahoo! Mail has the best spam protection around 
http://mail.yahoo.com 


-------------------------------------------------------
This SF.Net email is sponsored by: IntelliVIEW -- Interactive Reporting
Tool for open source databases. Create drag-&-drop reports. Save time
by over 75%! Publish reports on the web. Export to DOC, XLS, RTF, etc.
Download a FREE copy at http://www.intelliview.com/go/osdn_nl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
