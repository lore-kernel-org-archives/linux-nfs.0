From: dumas@centre-cired.fr (Patrice DUMAS - DOCT)
Subject: Re: Locking patches (generic & nfs)
Date: Tue, 23 Jul 2002 18:32:50 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20020723183250.A30579@hermes.centre-cired.fr>
References: <20020719101950.A15819@suse.de> <shsy9c27asf.fsf@charged.uio.no> <20020723170615.D1869@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from boukha.centre-cired.fr ([193.51.120.234])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17X2of-000567-00
	for <nfs@lists.sourceforge.net>; Tue, 23 Jul 2002 09:47:22 -0700
Received: from hermes.centre-cired.fr ([193.51.120.92])
          by boukha.centre-cired.fr (8.9.3+Sun/jtpda-5.3.3) with ESMTP id SAA14346
          for <nfs@lists.sourceforge.net>; Tue, 23 Jul 2002 18:44:50 +0100 (WEST)
Received: (from dumas@localhost)
	by hermes.centre-cired.fr (8.11.6/8.11.6) id g6NGWq816979
	for nfs@lists.sourceforge.net; Tue, 23 Jul 2002 18:32:52 +0200
To: nfs@lists.sourceforge.net
In-Reply-To: <20020723170615.D1869@suse.de>; from okir@suse.de on Tue, Jul 23, 2002 at 05:06:15PM +0200
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

Hi,

> > Patrice Dumas recently did some work on implementing this both for
> > NLMv1,2,3 and NLM4, so I was planning on integrating his changes into
> > 2.4.20.
> 
> As you can see from the patch, it's not really much you need to add.
> The functionality is all there, one only needs to decode the GRANTED_RES
> call rather than dropping it.

This is basically all what is needed, however there are some
more issues raised when the server decode the GRANTED_RES calls I tried
to answer in other patches:

- if 2 clients use the same cookie, the blocks will be mixed up

- if the linux client GRANTED_RES is lost, it will get a GRANTED_MSG 
twice, the second GRANTED_RES will have a status set to nlm_lck_denied 
because in nlmclnt_grant the lock request won't be found. This in 
turn will cause the server to unlock the lock, while the client thinks
it is granted and potential file corruption. I made a fix on the
client side.

It doesn't solve the problem on the server side, but it seems to me that
the server side behaviour is the right behaviour (except in very rare cases
where there is a race condition I will try to solve in a next patch but
it is very rare and not urgent in my opinion).

Pat


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
