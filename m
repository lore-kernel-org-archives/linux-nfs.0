From: "Kevin Coffman" <kwc@citi.umich.edu>
Subject: Re: nfs4 with kerberos troubles
Date: Thu, 15 Mar 2007 10:04:34 -0400
Message-ID: <4d569c330703150704gde21a56id9c43576f40b7877@mail.gmail.com>
References: <904836.85940.qm@web34407.mail.mud.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: "Jonathan Schreiter" <jonathanschreiter@yahoo.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HRqZK-0002kY-IS
	for nfs@lists.sourceforge.net; Thu, 15 Mar 2007 07:04:38 -0700
Received: from wr-out-0506.google.com ([64.233.184.239])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HRqZM-0006D0-Hz
	for nfs@lists.sourceforge.net; Thu, 15 Mar 2007 07:04:40 -0700
Received: by wr-out-0506.google.com with SMTP id i21so182069wra
	for <nfs@lists.sourceforge.net>; Thu, 15 Mar 2007 07:04:40 -0700 (PDT)
In-Reply-To: <904836.85940.qm@web34407.mail.mud.yahoo.com>
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

On 3/14/07, Jonathan Schreiter <jonathanschreiter@yahoo.com> wrote:
> Hi all,
> I've been strugling to get NFS4 to work with my MIT Kerberos 5 infrastucture.  I have a server and client with Centos 4.4.  I'm using LDAP (Fedora Directory Server 1.4) for my POSIX accounts and KRB5 for the authentication.  I am able to get the NFS mounts to work when kerberos is not enabled.
>
>
> On the server, in /var/log/messages:
> mountd[2517]: mount request from unknown host myclientipaddress for /home/NFS4 (/home/NFS4)

I think it may be a dns issue, but I'm not sure why you wouldn't see
the error w/o Kerberos.  What does your /etc/exports look like on the
server?  Can you do a reverse dns lookup of the client's IP from the
server machine?

> I only found one other post referencing this, but it recommended the error be in
> the /etc/krb5.conf.  I have:
> .mydomain.com = MYREALM.COM
> mydomain.com = MYREALM.COM
> .mydomain.com = myrealm.com

You don't want that last line.  The first two are correct.

K.C.

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
