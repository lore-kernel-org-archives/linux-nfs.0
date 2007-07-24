From: "Steinar H. Gunderson" <sgunderson@bigfoot.com>
Subject: Re: Status of mount.nfs
Date: Tue, 24 Jul 2007 19:24:51 +0200
Message-ID: <20070724172451.GA14026@uio.no>
References: <20070708191640.GA13962@uio.no>
	<18065.43199.104020.412029@notabene.brown>
	<20070715083114.GB4158@uio.no>
	<18074.50730.591965.39211@notabene.brown>
	<20070716092047.GA10353@uio.no>
	<18075.17719.855332.259470@notabene.brown>
	<20070722191733.GA31501@uio.no> <46A52816.6050500@oracle.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="zYM0uCDKw75PZbzx"
Cc: nfs@lists.sourceforge.net
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IDO7y-0004oe-NH
	for nfs@lists.sourceforge.net; Tue, 24 Jul 2007 10:24:54 -0700
Received: from cassarossa.samfundet.no ([129.241.93.19] ident=Debian-exim)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IDO80-0007qm-S4
	for nfs@lists.sourceforge.net; Tue, 24 Jul 2007 10:24:58 -0700
In-Reply-To: <46A52816.6050500@oracle.com>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net


--zYM0uCDKw75PZbzx
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline

On Mon, Jul 23, 2007 at 06:13:42PM -0400, Chuck Lever wrote:
> It would help if we could take a look at a clean network trace of the bad 
> and the good mount operations.

It was quite simple to test this myself. I started the kernel server on a
machine, then shut down portmap. First I did:

  fugl:~> sudo mount -t nfs -o port=2049,mountport=901,nfsvers=3 192.168.0.101:/ /mnt
  mount: mount to NFS server '192.168.0.101' failed: System Error: Connection refused.

The dump is attached as "default.dump". Then I did

  fugl:~> sudo mount -t nfs -o port=2049,mountport=901,nfsvers=3,udp 192.168.0.101:/ /mnt 

which is attached as "udp.dump".

Note that in default.dump, UDP is simply never tried at all. I believe that
to be a bug.

/* Steinar */
-- 
Homepage: http://www.sesse.net/

--zYM0uCDKw75PZbzx
Content-Type: application/octet-stream
Content-Disposition: attachment; filename="default.dump"
Content-Transfer-Encoding: base64

1MOyoQIABAAAAAAAAAAAAP//AAABAAAAjTWmRoEEDQBKAAAASgAAAADgGNjPKwATAqqc2AgA
RQAAPPYnQABABsIzwKgAq8CoAGW/BQBvoC3vPAAAAACgAhbQQ+YAAAIEBbQEAggKAu8ZGwAA
AAABAwMHjTWmRuAIDQA8AAAAPAAAAAATAqqc2ADgGNjPKwgARQAAKAAAQABABrhvwKgAZcCo
AKsAb78FAAAAAKAt7z1QFAAA3o8AAAAAAAAAAI01pkZ6CQ0ASgAAAEoAAAAA4BjYzysAEwKq
nNgIAEUAADwpl0AAQAaOxMCoAKvAqABlA4wAb6CPMIwAAAAAoAIW0L2uAAACBAW0BAIICgLv
GRsAAAAAAQMDB401pkZfDQ0APAAAADwAAAAAEwKqnNgA4BjYzysIAEUAACgAAEAAQAa4b8Co
AGXAqACrAG8DjAAAAACgjzCNUBQAAFhYAAAAAAAAAAA=

--zYM0uCDKw75PZbzx
Content-Type: application/octet-stream
Content-Disposition: attachment; filename="udp.dump"
Content-Transfer-Encoding: base64

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

--zYM0uCDKw75PZbzx
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
--zYM0uCDKw75PZbzx
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--zYM0uCDKw75PZbzx--
