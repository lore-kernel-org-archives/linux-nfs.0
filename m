From: Andre van Hoorn <andre.van.hoorn@informatik.uni-oldenburg.de>
Subject: Re: [NFS] SUNRPC: Lack of RPC record fragments / Pynfs test WRT5
 - st_write.testLargeData
Date: Tue, 05 Sep 2006 09:48:35 +0200
Message-ID: <44FD2BD3.8010000@informatik.uni-oldenburg.de>
References: <44FC5F77.9010708@informatik.uni-oldenburg.de>
	<17660.46933.187475.92083@cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: NFSv4@linux-nfs.org, nfs@lists.sourceforge.net
Return-path: <nfsv4-bounces@linux-nfs.org>
To: Neil Brown <neilb@suse.de>
In-Reply-To: <17660.46933.187475.92083@cse.unsw.edu.au>
List-Unsubscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=unsubscribe>
List-Archive: <http://linux-nfs.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@linux-nfs.org>
List-Help: <mailto:nfsv4-request@linux-nfs.org?subject=help>
List-Subscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=subscribe>
Sender: nfsv4-bounces@linux-nfs.org
Errors-To: nfsv4-bounces@linux-nfs.org
List-ID: <nfs.lists.sourceforge.net>

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

Neil Brown schrieb:
> On Monday September 4, andre.van.hoorn@informatik.uni-oldenburg.de wrot=
e:
>> -----BEGIN PGP SIGNED MESSAGE-----
>> Hash: SHA1
>>
>> Hi,
>>
>>
>> I'm communicating with the linux NFS kernel server via RPC using the
>> sunrpc implementation in glibc. On certain RPC record sizes, glibc
>> starts to use record fragmentation (whereas the sunrpc kernel client
>> doesn't) and the sunrpc linux kernel server implementation lacks the R=
PC
>> record "defragmentation" functionality as can be seen in
>> net/sunrpc/svcsock.c:
>>
>> svsk->sk_reclen =3D ntohl(svsk->sk_reclen);
>> if (!(svsk->sk_reclen & 0x80000000)) {
>>   /* FIXME: technically, a record can be fragmented,
>>    *  and non-terminal fragments will not have the top
>>    *  bit set in the fragment length header.
>>    *  But apparently no known nfs clients send fragmented
>>    *  records. */
>>    printk(KERN_NOTICE "RPC: bad TCP reclen 0x%08lx (non-terminal)\n",
>>          (unsigned long) svsk->sk_reclen);
>>    goto err_delete;
>> }
>>
>> Unfortunately, I didn't find a way to disable the use of fragmentation
>> in glibc. Is there an existing patch for the kernel to support
>> fragmented records?
>=20
> Not that I am aware of, and it would be fairly non-trivial to
> implement, for relatively little gain.
>=20
> You should be able to avoid fragmentation with glibc by setting
> 'sendsz' large enough.
> When you call clnttcp_create, pass a big number for the 5th arg.
>=20
> NeilBrown
>=20

Thanks, calling clnttcp_create with sendsz=3D65724 avoids the
fragmentation by the glibc and NFS "splits" the packets instead.

I recognized (I don't know if I am the first one but I just read
http://linux-nfs.org/pipermail/nfsv4/2005-October/002760.html) the RPC
fragmentation problem (here in the python rpc lib instead of glibc)
could also be the reason why Pynfs test "WRT5 - st_write.testLargeData"
fails -- if this is still the case.

Executing this test on my system, the nfs server (respectively sunrpc)
dumps the message "RPC: bad TCP reclen 0x00000800 (non-terminal)".




Andr=E9
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org

iD8DBQFE/SvTLKwmE5jzZmkRAr+bAJ4hguBP13iU3VKg2glLkZ4pR4rOugCg3QTe
9Wz2dLaOEPMHYBsyh48nKsk=3D
=3DIkcs
-----END PGP SIGNATURE-----
