From: Jonathan Schreiter <jonathanschreiter@yahoo.com>
Subject: Re: nfs4 with kerberos troubles
Date: Thu, 15 Mar 2007 18:52:17 -0700 (PDT)
Message-ID: <600939.16106.qm@web34411.mail.mud.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: Kevin Coffman <kwc@citi.umich.edu>, nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HS1cE-0002Er-Uv
	for nfs@lists.sourceforge.net; Thu, 15 Mar 2007 18:52:23 -0700
Received: from web34411.mail.mud.yahoo.com ([66.163.178.160])
	by mail.sourceforge.net with smtp (Exim 4.44) id 1HS1cF-0003b4-TZ
	for nfs@lists.sourceforge.net; Thu, 15 Mar 2007 18:52:25 -0700
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

it's centos 4.4 (rhel 4) and

kernel: 2.6.9-42.0.3.EL
nfs-utils-lib-1.0.6-3
nfs-utils-1.0.6-70.EL4

----- Original Message ----
From: Kevin Coffman <kwc@citi.umich.edu>
To: Jonathan Schreiter <jonathanschreiter@yahoo.com>
Cc: nfs@lists.sourceforge.net
Sent: Thursday, March 15, 2007 6:32:52 PM
Subject: Re: [NFS] nfs4 with kerberos troubles


I've not ever seen this error personally.  I'm still stumped on why
you only see it with Kerberos.

What kernel and nfs-utils versions are involved here?


On 3/15/07, Jonathan Schreiter <jonathanschreiter@yahoo.com> wrote:
> Hi Kevin,
> I am able to forward and reverse lookup the server and client via DNS from both machines.  The only change required from my setup to make this work is to replace the gss/krb with * in the /etc/exports file (and a service nfs restart on the nfsserver).
>
> Any other thoughts?
>
> Thanks!
> Jonathan
>
> ----- Original Message ----
> From: Kevin Coffman <kwc@citi.umich.edu>
> To: Jonathan Schreiter <jonathanschreiter@yahoo.com>
> Cc: nfs@lists.sourceforge.net
> Sent: Thursday, March 15, 2007 10:06:29 AM
> Subject: Re: [NFS] nfs4 with kerberos troubles
>
>
> On 3/15/07, Kevin Coffman <kwc@citi.umich.edu> wrote:
> > On 3/14/07, Jonathan Schreiter <jonathanschreiter@yahoo.com> wrote:
> > > On the server, in /var/log/messages:
> > > mountd[2517]: mount request from unknown host myclientipaddress for /home/NFS4 (/home/NFS4)
> >
> > I think it may be a dns issue, but I'm not sure why you wouldn't see
> > the error w/o Kerberos.  What does your /etc/exports look like on the
> > server?  Can you do a reverse dns lookup of the client's IP from the
> > server machine?
>
> Sorry,  I know you had the /etc/exports in the original message.  I
> meant to remove that before sending the message :-/
>
>

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
