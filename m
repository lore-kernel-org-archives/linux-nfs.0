From: mehta kiran <kiranmehta1981@yahoo.com>
Subject: Re: lockd grace period
Date: Mon, 31 Jan 2005 07:09:55 -0800 (PST)
Message-ID: <20050131150955.81041.qmail@web51610.mail.yahoo.com>
References: <41FE4867.4070709@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Aswathanarayana, Chetan (STSD)" <chetan.aswathanarayana@hp.com>,
	nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CvdBj-0002WP-Gy
	for nfs@lists.sourceforge.net; Mon, 31 Jan 2005 07:10:03 -0800
Received: from web51610.mail.yahoo.com ([206.190.38.215])
	by sc8-sf-mx2.sourceforge.net with smtp (Exim 4.41)
	id 1CvdBh-0002qA-7R
	for nfs@lists.sourceforge.net; Mon, 31 Jan 2005 07:10:03 -0800
To: Steve Dickson <SteveD@redhat.com>
In-Reply-To: <41FE4867.4070709@RedHat.com>
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

Hi , 
     lockd can run alone if this machine also acts
as nfs client of some other (third machine)
Clients side only require lockd and rpciod , right 
thanks,
kiran
--- Steve Dickson <SteveD@redhat.com> wrote:

> 
> 
> mehta kiran wrote:
> 
> >Hi , 
> >          this means that if  lockd alone is
> running
> >since a long time and if now i start nfsd , 
> >
> hmm... why would you ever have lockd running
> "alone"?
> Meaning what good is it w/out rpc.nfsd? Also how are
> you doing that since one of the first things
> rpc.nfsd does
> is bring up lockd().....
> 
> steved.
> 
> 
> 
>
-------------------------------------------------------
> This SF.Net email is sponsored by: IntelliVIEW --
> Interactive Reporting
> Tool for open source databases. Create drag-&-drop
> reports. Save time
> by over 75%! Publish reports on the web. Export to
> DOC, XLS, RTF, etc.
> Download a FREE copy at
> http://www.intelliview.com/go/osdn_nl
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs
> 



		
__________________________________ 
Do you Yahoo!? 
Yahoo! Mail - 250MB free storage. Do more. Manage less. 
http://info.mail.yahoo.com/mail_250


-------------------------------------------------------
This SF.Net email is sponsored by: IntelliVIEW -- Interactive Reporting
Tool for open source databases. Create drag-&-drop reports. Save time
by over 75%! Publish reports on the web. Export to DOC, XLS, RTF, etc.
Download a FREE copy at http://www.intelliview.com/go/osdn_nl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
