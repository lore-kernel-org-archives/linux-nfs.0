From: "Kevin Coffman" <kwc@citi.umich.edu>
Subject: Re: can not start NFSv4 with Kerberos 5
Date: Wed, 4 Apr 2007 11:30:28 -0400
Message-ID: <4d569c330704040830r10e22040hb774769871f198ae@mail.gmail.com>
References: <1175595021.3798.19.camel@localhost.localdomain>
	<89c397150704030446id0db9b1h30e20cfba0f5182a@mail.gmail.com>
	<1175602407.4063.51.camel@localhost.localdomain>
	<89c397150704030618iee707a8v24b1cbeb0dd72502@mail.gmail.com>
	<4d569c330704030721i1b4c8d52t7a78bbf2e06fd221@mail.gmail.com>
	<1175653041.2998.11.camel@milan>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, mzeng@plasmon.cn
To: Phillip <phuang@plasmon.cn>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HZ7RO-0001qu-Cn
	for nfs@lists.sourceforge.net; Wed, 04 Apr 2007 08:30:30 -0700
Received: from ik-out-1112.google.com ([66.249.90.181])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HZ7RO-0003A3-Dv
	for nfs@lists.sourceforge.net; Wed, 04 Apr 2007 08:30:32 -0700
Received: by ik-out-1112.google.com with SMTP id c30so178939ika
	for <nfs@lists.sourceforge.net>; Wed, 04 Apr 2007 08:30:29 -0700 (PDT)
In-Reply-To: <1175653041.2998.11.camel@milan>
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

On 4/3/07, Phillip <phuang@plasmon.cn> wrote:
> Hello Andy & Kevin,
>
> Thanks for your kindly help.
>
> Yes, I create the keytab by "nfs/nfsv4@PLASMON.SIT" and start rpc.gssd
> and rpc.svcgssd successfully. nfsv4 is the hostname of NFS server, and
> PLASMON.SIT is the AD domain.

For your reference - when working with Kerberos, the "instance" part
of the principal name (the part between the "/" and the "@") should be
the host's fully-qualified-domain-name (fqdn).  So you *should* have a
principal, "nfs/nfsv4.plascom.sit@PLASMON.SIT" or something like that.

> When Set Windows2K as KDC for NFSv4, is it necessary to user Ktpass
> tools to create keytab in the KDC server(Windows), and copy the keytabs
> to NFS server and clients?
>
> If so, it seems to be complicated and causes security problems while
> users have to log and access KDC server frequently.
>
> Is there other easy way to do this? We do not want to make the end-users
> confused.

There are tools that allow you to create the keytab directly from the
NFS server and client machine, one example is described here:
http://mailman.mit.edu/pipermail/kerberos/2007-March/011423.html,
there are probably others.  Otherwise, yes you must create the keytab
on the Windows machine and transfer it to the Linux machines.

K.C.

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
