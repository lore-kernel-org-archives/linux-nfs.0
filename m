From: Janos Farkas <chexum+dev@gmail.com>
Subject: Re: nfs problems with 2.6.18-rc1
Date: Mon, 17 Jul 2006 13:25:26 +0200
Message-ID: <priv$8d118c145616$a76e56732d@200607.shadow.banki.hu>
References: <priv$8d118c145575$b19af6759a@200607.shadow.banki.hu>
	<1153127026.2871.12.camel@frecb000687.frec.bull.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Cc: =?iso-8859-1?Q?Aim=E9?= Le Rouzic <Aime.Le-Rouzic@bull.net>,
	nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1G2REb-0003rE-JA
	for nfs@lists.sourceforge.net; Mon, 17 Jul 2006 04:25:57 -0700
Received: from nf-out-0910.google.com ([64.233.182.185])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1G2REa-0006zL-KI
	for nfs@lists.sourceforge.net; Mon, 17 Jul 2006 04:25:58 -0700
Received: by nf-out-0910.google.com with SMTP id m19so460539nfc
	for <nfs@lists.sourceforge.net>; Mon, 17 Jul 2006 04:25:54 -0700 (PDT)
To: Tony Reix <tony.reix@bull.net>
In-Reply-To: <1153127026.2871.12.camel@frecb000687.frec.bull.fr>
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

On 2006-07-17 at 11:03:46, Tony Reix wrote:
> Le jeudi 13 juillet 2006 ? 20:22 +0200, Janos Farkas a =E9crit :
> > I recently updated two (old) hosts to 2.6.18-rc1, and started
> > noticing
> > weird things with the nfs mounted /home s.
> >
> > I frequently face EACCESs where a few minutes ago there wasn't any
> > problem, and after a retry everything does work again.
> Do you have the same problem with the last stable version (2.6.17-rc2)
> we have tested with in depth ?
> See:  http://nfsv4.bullopensource.org/

Even stock 2.6.17 as server works for me with a 2.6.18-rc1 client (v3).

--
Janos
romfs is at http://romfs.sourceforge.net/


-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easi=
er
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=3Dlnk&kid=3D120709&bid=3D263057&dat=3D1=
21642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
