From: Frank Steiner <fsteiner-mail@bio.ifi.lmu.de>
Subject: Re: read-error on utmp file
Date: Tue, 07 Sep 2004 08:43:15 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <413D5883.1080509@bio.ifi.lmu.de>
References: <41383991.1020108@bio.ifi.lmu.de>	 <1094230320.8196.32.camel@lade.trondhjem.org>	 <413C0F25.9010206@bio.ifi.lmu.de> <1094490287.8342.69.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1C4ZhP-00006z-DH
	for nfs@lists.sourceforge.net; Mon, 06 Sep 2004 23:43:27 -0700
Received: from acheron.informatik.uni-muenchen.de ([129.187.214.135])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.34)
	id 1C4ZhL-0006E2-IB
	for nfs@lists.sourceforge.net; Mon, 06 Sep 2004 23:43:27 -0700
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1094490287.8342.69.camel@lade.trondhjem.org>
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

Hi Trond,

Trond Myklebust wrote:
> P=E5 m=E5 , 06/09/2004 klokka 03:17, skreiv Frank Steiner:
>=20
>=20
>>tcpdump -s 9000 -w <file> host curry & while runlevel /boot/utmp; do tr=
ue; done; killall tcpdump
>>
>>and started the second loop in another window which caused this first l=
oop
>>to fail and stop the tcpdump...
>=20
>=20
> Ah, right... Sorry, my head hasn't been screwed on correctly...
>=20
> Although we wait on writes, we don't bother to wait on all *reads* to
> complete when closing the file. This means that readahead (which can
> schedule extra pageins asynchronously) may end up causing the file to b=
e
> kept open for longer.
>=20
> That is why you are seeing sillyrenames here...

sorry, I don't understand what you are trying to tell me :-) I'm not sure=

what you mean by "silly renames". I didn't see any .nfsxxx files or sth.
similar like it is discussed in the "silly names" thread.
My problem was that two concurrent reads on with /sbin/runlevel on an
utmp file would cause one read to abort with I/O error.

However, the sentence I might understand is that a process could close
a file although some other process is still reading on it? So that the
process still reading gets an I/O error because the file is closed?
If that's what happening, wouldn't that be a bug? I can think of many
situations where two processes are reading from the same file, and
I feel that one process should not be able to close the file such that
the other process still reading aborts with I/O error?

But I might have missed the point of your answer... :-/

cu,
Frank


--=20
Dipl.-Inform. Frank Steiner   Web:  http://www.bio.ifi.lmu.de/~steiner/
Lehrstuhl f. Bioinformatik    Mail: http://www.bio.ifi.lmu.de/~steiner/m/=

LMU, Amalienstr. 17           Phone: +49 89 2180-4049
80333 Muenchen, Germany       Fax:   +49 89 2180-99-4049
* Rekursion kann man erst verstehen, wenn man Rekursion verstanden hat. *=



-------------------------------------------------------
This SF.Net email is sponsored by BEA Weblogic Workshop
FREE Java Enterprise J2EE developer tools!
Get your free copy of BEA WebLogic Workshop 8.1 today.
http://ads.osdn.com/?ad_id=5047&alloc_id=10808&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
