From: "Peter W. Draper" <p.w.draper@durham.ac.uk>
Subject: Re: Using mmap result in data corruption
Date: Tue, 8 Mar 2005 14:41:57 +0000 (GMT)
Message-ID: <Pine.LNX.4.44.0503081417180.19681-100000@starpc8.phyast.dur.ac.uk>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1D8fuW-0001Er-JH
	for nfs@lists.sourceforge.net; Tue, 08 Mar 2005 06:42:12 -0800
Received: from hermes.dur.ac.uk ([129.234.4.9])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1D8fuU-0008D3-Sj
	for nfs@lists.sourceforge.net; Tue, 08 Mar 2005 06:42:12 -0800
Received: from dust0.dur.ac.uk (dust0.dur.ac.uk [129.234.8.70])
	by hermes.dur.ac.uk (8.11.7-20030923/8.11.7) with ESMTP id j28Efw226612
	for <nfs@lists.sourceforge.net>; Tue, 8 Mar 2005 14:41:58 GMT
Received: from starpc8.phyast.dur.ac.uk (starpc8.phyast.dur.ac.uk [129.234.184.206])
	by dust0.dur.ac.uk (8.11.7+Sun/8.9.1) with ESMTP id j28EfwI05225
	for <nfs@lists.sourceforge.net>; Tue, 8 Mar 2005 14:41:58 GMT
Received: from starpc8.phyast.dur.ac.uk (localhost [127.0.0.1])
	by starpc8.phyast.dur.ac.uk (8.12.8/8.12.8) with ESMTP id j28EfwRT019774
	for <nfs@lists.sourceforge.net>; Tue, 8 Mar 2005 14:41:58 GMT
Received: from localhost (pdraper@localhost)
	by starpc8.phyast.dur.ac.uk (8.12.8/8.12.8/Submit) with ESMTP id j28EfvhJ019770
	for <nfs@lists.sourceforge.net>; Tue, 8 Mar 2005 14:41:58 GMT
To: nfs@lists.sourceforge.net
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

> > fr den 12.11.2004 Klokka 21:06 (+0200) skreiv Miika Pekkarinen:
> >
> > I have found a reproducable issue with NFS that will lead to file
> > corruption on server. When a file is created with O_TRUNC and data is
> > copied using mmap, the new file on the server will be filled with null
> > bytes.
> 
> mmap() offers absolutely NO guarantees that the file will be synced to
> disk on close. Use msync(MS_SYNC) if you want such a guarantee.
> 
> Cheers,
>  Trond

Hi,

like Miika I have noticed that mapped files updated over NFS are now
corrupted on the server. For me this problem looks like it arrived with
2.6.9 and is still causing problems with 2.6.11 (I'm running various
Fedora Core 2/3 clients together with various Linux and non-Linux NFS
servers, all using NFS v3).

Following Trond's advice I've changed to using an msync() call before
munmap() and that fixes the problem.  However, I'd really like to avoid
the potential performance impact of using an msync(MS_SYNC) by using an
msync(MS_ASYNC) call instead, as the files I access can be mmap'd many
times, plus can be quite large, but, when I switch to msync(MS_ASYNC) the
data corruption returns (I am only interested in the correctness of the
data when my applications exit).

Surely that is incorrect behaviour? Otherwise what is the point of
msync(MS_ASYNC)?

Thanks for any help/advice on this,

Peter.

-- 
Dr. Peter W. Draper, Starlink Programmer,     http://star-www.dur.ac.uk/~pdraper



-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
