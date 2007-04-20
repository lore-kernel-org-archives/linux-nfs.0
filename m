From: "Kevin Coffman" <kwc@citi.umich.edu>
Subject: Re: svc_process and nfsd_proc_read not taking checksum into
	account when calling svc_reserve
Date: Fri, 20 Apr 2007 13:57:55 -0400
Message-ID: <4d569c330704201057l1ba2a131r39df22db6e917fb3@mail.gmail.com>
References: <4628D19F.5080805@redhat.com> <20070420174748.GG19285@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, Jeff Layton <jlayton@redhat.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HexMq-000520-7O
	for nfs@lists.sourceforge.net; Fri, 20 Apr 2007 10:57:56 -0700
Received: from wr-out-0506.google.com ([64.233.184.225])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HexMr-00080p-Mg
	for nfs@lists.sourceforge.net; Fri, 20 Apr 2007 10:57:58 -0700
Received: by wr-out-0506.google.com with SMTP id i20so1787605wra
	for <nfs@lists.sourceforge.net>; Fri, 20 Apr 2007 10:57:57 -0700 (PDT)
In-Reply-To: <20070420174748.GG19285@fieldses.org>
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

On 4/20/07, J. Bruce Fields <bfields@fieldses.org> wrote:
>
> You don't need to know the exact amount, just an upper bound, right?
>
> In which case I'd be tempted to just look at some krb5i and krb5p
> traffic in wireshark, figure out how much it adds (it should always be
> the same, except that krb5p pads the arguments to the nearest 8-byte
> boundary, which will add padding that varies between 1 and 8 bytes.)

Is the length going to depend on the Kerberos encryption-type as well?

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
