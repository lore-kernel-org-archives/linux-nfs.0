From: Dumas Patrice <dumas@centre-cired.fr>
Subject: lockd bug (?)
Date: Mon, 8 Apr 2002 12:59:28 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20020408125928.A12049@zeus.centre-cired.fr>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="4Ckj6UjgE2iN1+kY"
Received: from boukha.centre-cired.fr ([193.51.120.234])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 16uWvX-0002cX-00
	for <nfs@lists.sourceforge.net>; Mon, 08 Apr 2002 04:03:12 -0700
Received: from zeus.centre-cired.fr ([193.51.120.192])
          by boukha.centre-cired.fr (8.9.3+Sun/jtpda-5.3.3) with ESMTP id NAA26833
          for <nfs@lists.sourceforge.net>; Mon, 8 Apr 2002 13:02:13 +0100 (WEST)
Received: (from dumas@localhost)
	by zeus.centre-cired.fr (8.11.6/8.11.6) id g38AxTF13109
	for nfs@lists.sourceforge.net; Mon, 8 Apr 2002 12:59:29 +0200
To: nfs@lists.sourceforge.net
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


--4Ckj6UjgE2iN1+kY
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi,

I send a message before but nobody answered. I made some tests, they seem to
prove what I said. What did I say ? A blocked lock is never deleted and lockd
continues sending granted callbacks, even when the client responded to the
callback.

Here is my test:

Everything is on zeus, I mounted a filesystem locally:

mount zeus:/cired/zeus/home /mnt/tmp

Then I use the testlk from nfs-utils:

[dumas@terminal1.zeus locktest]$ ./testlk /mnt/tmp/dumas/testlock 
fcntl: ok

In another terminal I reuse ./testlk to have a blocked lock:
[dumas@terminal2.zeus locktest]$ ./testlk /mnt/tmp/dumas/testlock -b

Then I do a ctrl-C on the first terminal, I get
[dumas@terminal1.zeus locktest]$ ./testlk /mnt/tmp/dumas/testlock
fcntl: ok

[dumas@terminal1.zeus locktest]$

Then on the second terminal, the lock is granted and thus I get
[dumas@terminal2.zeus locktest]$ ./testlk /mnt/tmp/dumas/testlock -b
fcntl: ok

I don't stop that one, because my point is that now lockd will keep on sending
unneeded callbacks, because it does nothing with the responses of the client. I
attached the dmesg output. I commented it a bit with #comment


--4Ckj6UjgE2iN1+kY
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=dmesg

nlmsvc_retry_blocked(cd5e4800, when=275813652)
nlmsvc_retry_blocked(cd5e4800, when=275813652)
nlmsvc_retry_blocked(cd5e4800, when=275813652, done=0)
lockd: grant blocked lock cd5e4800                     #server want to regrant
lockd: rebind host 193.51.120.192
lockd: GRANTing blocked lock.
lockd: nlmsvc_insert_block(cd5e4800, 3000)             #schedule next grant
lockd: get host 193.51.120.192
lockd: call procedure nlm_granted_msg on 193.51.120.192 (async)
lockd: nlm_bind_host(c13378c0)
lockd: GRANT_MSG RPC callback                          #client responded
callback: looking for cookie 1235                      
cookie: head of blocked queue cd5e4800, block cd5e4800
lockd: nlmsvc_insert_block(cd5e4800, 6000)
lockd: release host 193.51.120.192
lockd: request from c13378c0                           #client side
lockd: GRANTED_MSG   called
lockd: GRANTED       called
lockd: GRANTED       status 1    #status is 1 because lock is allready granted
lockd: nlm_lookup_host(c13378c0, p=17, v=4)            
lockd: host garbage collection
lockd: nlmsvc_mark_resources
lockd: get host 193.51.120.192
lockd: call procedure nlm_granted_res on 193.51.120.192 (async) #client calls
lockd: nlm_bind_host(c13378c0)
lockd: release host 193.51.120.192
nlmsvc_retry_blocked(cd5e4800, when=275819652)
lockd: request from c13378c0
lockd: NULL          called     #server get granted_res but calls the null proc
nlmsvc_retry_blocked(cd5e4800, when=275819652)
nlmsvc_retry_blocked(cd5e4800, when=275819652)
nlmsvc_retry_blocked(cd5e4800, when=275819652)
nlmsvc_retry_blocked(cd5e4800, when=275819652, done=0)
lockd: grant blocked lock cd5e4800                       #one more time...
lockd: rebind host 193.51.120.192
lockd: GRANTing blocked lock.
lockd: nlmsvc_insert_block(cd5e4800, 3000)
lockd: get host 193.51.120.192
lockd: call procedure nlm_granted_msg on 193.51.120.192 (async)
lockd: nlm_bind_host(c13378c0)
lockd: GRANT_MSG RPC callback
callback: looking for cookie 1235 
cookie: head of blocked queue cd5e4800, block cd5e4800
lockd: nlmsvc_insert_block(cd5e4800, 6000)
lockd: release host 193.51.120.192
lockd: request from c13378c0
lockd: GRANTED_MSG   called
lockd: GRANTED       called
lockd: GRANTED       status 1
lockd: nlm_lookup_host(c13378c0, p=17, v=4)
lockd: host garbage collection
lockd: nlmsvc_mark_resources
lockd: get host 193.51.120.192
lockd: call procedure nlm_granted_res on 193.51.120.192 (async)
lockd: nlm_bind_host(c13378c0)
lockd: release host 193.51.120.192
nlmsvc_retry_blocked(cd5e4800, when=275825652)
lockd: request from c13378c0
lockd: NULL          called
nlmsvc_retry_blocked(cd5e4800, when=275825652)
nlmsvc_retry_blocked(cd5e4800, when=275825652)

--4Ckj6UjgE2iN1+kY--

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
