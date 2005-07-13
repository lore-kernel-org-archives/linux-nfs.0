From: Chris Penney <cpenney@gmail.com>
Subject: Re: NFS Client Performance Question
Date: Wed, 13 Jul 2005 15:57:40 -0400
Message-ID: <111aefd050713125751db40c8@mail.gmail.com>
References: <482A3FA0050D21419C269D13989C611308539DA7@lavender-fe.eng.netapp.com>
	 <111aefd05071311553ac3d52a@mail.gmail.com>
	 <42D566FE.3060300@redhat.com>
Reply-To: penney@msu.edu
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DsnN8-0003av-Pk
	for nfs@lists.sourceforge.net; Wed, 13 Jul 2005 12:58:22 -0700
Received: from wproxy.gmail.com ([64.233.184.202])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.44)
	id 1DsnN7-00012H-LK
	for nfs@lists.sourceforge.net; Wed, 13 Jul 2005 12:58:23 -0700
Received: by wproxy.gmail.com with SMTP id i23so256079wra
        for <nfs@lists.sourceforge.net>; Wed, 13 Jul 2005 12:58:15 -0700 (PDT)
To: nfs@lists.sourceforge.net
In-Reply-To: <42D566FE.3060300@redhat.com>
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

On 7/13/05, Peter Staubach <staubach@redhat.com> wrote:
> Chris Penney wrote:
>=20
> >The Itanium page size is 16k (unless I'm mistaken) and the r/wsize is
> >32k so can that still be it?  Or are you saying that it is because the
> >size of the write is only 4k?
> >
>=20
> Well, it is curious that the over the wire WRITE requests are still only =
4K.
> The Sun server is not restricting the transfer sizes, so apparently
> something
> else is.
>=20
> You say that the application on the client is doing random, 4K writes to
> the file?  Is the file opened with O_SYNC or anything special like that?

I'm using a benchmark program (iozone) as it roughly simulations the
real application.  The way I am running it is such that it will
randomly write 4k chunks of the file until the whole file is
rewritten.  So each 4k write should be corrosponding to a specifc
chunk being writen.  What I don't understand is why they are not async
(I'm not an expert at all on NFS).

I reran the test using various chunk sizes and I found that if I use
'-r' to specify 8k or more it always uses async writes.  If I use 6,
4, or 2k I get a lot of fsync writes.  They aren't /always/ fsynced
writes, but most of them are.  I'll see a steam of fsync write, then a
few async, and then back to fsync.

   Chris


-------------------------------------------------------
This SF.Net email is sponsored by the 'Do More With Dual!' webinar happening
July 14 at 8am PDT/11am EDT. We invite you to explore the latest in dual
core and dual graphics technology at this free one hour event hosted by HP, 
AMD, and NVIDIA.  To register visit http://www.hp.com/go/dualwebinar
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
