From: "Kevin Coffman" <kwc@citi.umich.edu>
Subject: Re: nfs4 with kerberos troubles
Date: Thu, 15 Mar 2007 10:06:29 -0400
Message-ID: <4d569c330703150706m2aa1fe2h81d071c910e79e7d@mail.gmail.com>
References: <904836.85940.qm@web34407.mail.mud.yahoo.com>
	<4d569c330703150704gde21a56id9c43576f40b7877@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: "Jonathan Schreiter" <jonathanschreiter@yahoo.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HRqbB-0002xD-Ux
	for nfs@lists.sourceforge.net; Thu, 15 Mar 2007 07:06:34 -0700
Received: from ug-out-1314.google.com ([66.249.92.169])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HRqbD-0005aE-4i
	for nfs@lists.sourceforge.net; Thu, 15 Mar 2007 07:06:36 -0700
Received: by ug-out-1314.google.com with SMTP id z38so341126ugc
	for <nfs@lists.sourceforge.net>; Thu, 15 Mar 2007 07:06:30 -0700 (PDT)
In-Reply-To: <4d569c330703150704gde21a56id9c43576f40b7877@mail.gmail.com>
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

On 3/15/07, Kevin Coffman <kwc@citi.umich.edu> wrote:
> On 3/14/07, Jonathan Schreiter <jonathanschreiter@yahoo.com> wrote:
> > On the server, in /var/log/messages:
> > mountd[2517]: mount request from unknown host myclientipaddress for /home/NFS4 (/home/NFS4)
>
> I think it may be a dns issue, but I'm not sure why you wouldn't see
> the error w/o Kerberos.  What does your /etc/exports look like on the
> server?  Can you do a reverse dns lookup of the client's IP from the
> server machine?

Sorry,  I know you had the /etc/exports in the original message.  I
meant to remove that before sending the message :-/

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
