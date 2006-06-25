From: "Simon Matthews" <simon.d.matthews+nfs@gmail.com>
Subject: Re: Number of nfsd processes?
Date: Sun, 25 Jun 2006 13:13:52 -0700
Message-ID: <40b437200606251313t649fc76agd352e88c9a2bd252@mail.gmail.com>
References: <40b437200606241759u3ec0ccd7q578c1ac476d498d9@mail.gmail.com>
	<17566.23170.136301.392306@cse.unsw.edu.au>
	<1151242251.23280.5.camel@pc>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1FuazT-000328-7G
	for nfs@lists.sourceforge.net; Sun, 25 Jun 2006 13:13:55 -0700
Received: from py-out-1112.google.com ([64.233.166.179])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1FuazS-0001PZ-1u
	for nfs@lists.sourceforge.net; Sun, 25 Jun 2006 13:13:55 -0700
Received: by py-out-1112.google.com with SMTP id f28so1163268pyf
	for <nfs@lists.sourceforge.net>; Sun, 25 Jun 2006 13:13:52 -0700 (PDT)
To: "Brian J. Murrell" <brian@interlinx.bc.ca>
In-Reply-To: <1151242251.23280.5.camel@pc>
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

Brian (and others):

On 6/25/06, Brian J. Murrell <brian@interlinx.bc.ca> wrote:
> Neil,
>
> Your description was a bit ungrokkable.  Let me try to put some real
> world values to it and try to make it out...

Here are my numbers:
more /proc/net/rpc/nfsd
rc 58145 148831950 678877510
fh 126136 0 0 0 0
io 3843561989 2872416345
th 64 750787 29187.339 10107.193 6025.710 3273.713 3225.384 1680.524
725.219 1305.846 780.037 3180.079
....

Do these numbers ever get re-set? For example, I have re-started the
nfs server process (to increas the number of nfsd processes), but I
suspec the numbers merely keep aggregating, so they don't show what is
happening now (with 64 processes).

Regards,
Simon

Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
