From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: can't get request slot, write timeout
Date: 12 Aug 2002 20:47:52 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <shsadnroqw7.fsf@charged.uio.no>
References: <Pine.LNX.4.44.0208121320300.32192-100000@kenzo.iwr.uni-heidelberg.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Kenneth Howlett <aw464@osfn.org>,  nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from pat.uio.no ([129.240.130.16])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17eKEQ-0002CG-00
	for <nfs@lists.sourceforge.net>; Mon, 12 Aug 2002 11:47:58 -0700
To: Bogdan Costescu <bogdan.costescu@iwr.uni-heidelberg.de>
In-Reply-To: <Pine.LNX.4.44.0208121320300.32192-100000@kenzo.iwr.uni-heidelberg.de>
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://www.geocrawler.com/redir-sf.php3?list=nfs>

>>>>> " " == Bogdan Costescu <bogdan.costescu@iwr.uni-heidelberg.de> writes:

    >> In the FAQ it says that tcp is faster than udp on congested
    >> networks.  I think the same effect could be achieved by using
    >> udp with a small rsize/wsize.

     > That's debatable. TCP is supposed to handle these cases well
     > 'cause that's what it was designed for. The NFS client over UDP
     > just recently got better behaviour through Trond's efforts, but
     > having it perform just as over TCP would probably mean
     > re-implementing TCP within NFS. Eh, now Trond can shoot me :-)

No, I agree 100% with what Bogdan said above.

I wasn't aware that you'd seen better behaviour with the last set of
patches. Feedback is always welcome - particularly now when I'm trying
to work out exactly what we should aim to get into kernel 2.4.20! 

The most likely explanation for the improved behaviour would be that
those patches implement most of the known TCP performance tricks for
congested networks. The only TCP trick we cannot implement is that of
sending messages of length > 1.5k without using fragmentation. That
again means that if 1 fragment is lost, we have to resend 32k (or 8k
or whatever the r/wsize is set to) rather than only the 1.5k that was
actually missing...

The above is why the NFSv4 protocol explicitly specifies that NFS over
TCP *must* be supported, whereas NFS over UDP will only be
optional (In practice most implementations are likely to support both).

Cheers,
  Trond


-------------------------------------------------------
This sf.net email is sponsored by: Dice - The leading online job board
for high-tech professionals. Search and apply for tech jobs today!
http://seeker.dice.com/seeker.epl?rel_code=31
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
