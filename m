From: Marc Schmitt <mschmitt@inf.ethz.ch>
Subject: Re: Linux Client -> Solaris Server
Date: Wed, 02 Jun 2004 20:37:35 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <40BE1E6F.5040204@inf.ethz.ch>
References: <40BDE65F.1000009@inf.ethz.ch> <1086189852.17378.66.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BVaZR-0000Vr-Qv
	for nfs@lists.sourceforge.net; Wed, 02 Jun 2004 11:34:37 -0700
Received: from xsmtp.ethz.ch ([129.132.97.6])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.30)
	id 1BVaZR-0005TL-At
	for nfs@lists.sourceforge.net; Wed, 02 Jun 2004 11:34:37 -0700
In-Reply-To: <1086189852.17378.66.camel@lade.trondhjem.org>
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

Trond Myklebust wrote:

> På on , 02/06/2004 klokka 07:38, skreiv Marc Schmitt:
> 
> 
>>that the network layer is ok. I did the test using -o 
>>tcp,nfsvers=3,rsize=32768,wsize=32768, too, it made no difference at all.
> 
> 
> Exactly how did you do this test? Could you check that the
> tcp,rsize=32k,wsize=32k also turn up in /proc/mounts, and then retest?
> 
> The reason I ask is that there are 2 things that could corrupt your
> test:
> 
>   You used "-oremount" to change from udp to tcp. That won't work!
> 
>   You may have had the same filesystem mounted as udp on another
> mountpoint. In that case the udp filesystem will be replicated on the
> new mountpoint.

Indeed, the second case could have happened. I ran the test again, 
making sure that the export is only mounted once and that the mount 
options I specified appear in /proc/mounts. The result is the same, I 
get a throughput of 2.44 MB/s. Just to make sure that the client is not 
buggy, I made the same test mounting a RH 7.3 server, RHEL 3 default 
mount options, it completes in 3'20" which means whooping 10 MB/s.

	Marc



-------------------------------------------------------
This SF.Net email is sponsored by the new InstallShield X.
