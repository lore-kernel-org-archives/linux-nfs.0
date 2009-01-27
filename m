From: Julius <commercials@gmx.net>
Subject: Re: nfs4 with sec=krb5, mount times out
Date: Tue, 27 Jan 2009 05:08:49 +0100
Message-ID: <1233029329.6414.15.camel@wf.localdomain.de>
References: <1232994250.3310.221.camel@wf>
	 <4d569c330901261059x70913131j4dc1dec4809bc1f4@mail.gmail.com>
	 <1232997722.3694.2.camel@wf>
	 <4d569c330901261139ha362eddxb72681b57b4de64f@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: NFS list <linux-nfs@vger.kernel.org>
To: Kevin Coffman <kwc@citi.umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.gmx.net ([213.165.64.20]:50334 "HELO mail.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1751287AbZA0EIE convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 26 Jan 2009 23:08:04 -0500
In-Reply-To: <4d569c330901261139ha362eddxb72681b57b4de64f-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 2009-01-26 at 14:39 -0500, Kevin Coffman wrote:
> On Mon, Jan 26, 2009 at 2:22 PM, Julius <commercials@gmx.net> wrote:
> > On Mon, 2009-01-26 at 13:59 -0500, Kevin Coffman wrote:
> >> On Mon, Jan 26, 2009 at 1:24 PM, Julius <commercials@gmx.net> wrote:
> >> > Hi,
> >> >
> >> >
> >> > i can mount my nfsv4 share without kerberos security without
> >> > problems.../etc/fstab:
> >> >
> >> > night_crawler.localdomain.de:/music /home/metalfan/nfs4-mount   nfs4    user
> >> > 0       0
> >> >
> >> >
> >> > but adding "sec=krb5" to the options list results in:
> >> >
> >> >
> >> > mount -v nfs4-mount/
> >> > mount.nfs4: timeout set for Mon Jan 26 15:44:05 2009
> >> > mount.nfs4: text-based options:
> >> > 'sec=krb5,clientaddr=141.x.x.x,addr=141.x.x.x
> >> > mount.nfs4: mount(2): Connection timed out
> >> >
> >> >
> >> > I read somewhere on the mailing list that only des-cbc-crc is supported
> >> > for nfs4, its the only keytype for my user metalfan.
> >> > "kinit metalfan" was run before attempting to mount.
> >> > i can use gssapi to connect to night_crawlers sshd with my local user,
> >> > which also does the nfs4 mount.
> >> >
> >> > krb5-kdc.log and krb5-default.log do not show any connections.
> >> > Where do you start troubleshooting?
> >>
> >> First step would be to verify that rpc.gssd is running on your client
> >> machine, and rpc.svcgssd is running on your server machine.
> >> You need to generate a keytab for your server (with only a des-cbc-crc
> >> key).  (nfs/<f.q.h.n>@<REALM>)
> >> You likely need to generate a keytab for your client as well.
> >>
> >> If all those are done, send output of rpc.gssd and rpc.svcgssd
> >> (running with option -vvv).
> >>
> >> I would point you at our FAQ page, but the web server is sadly still
> >> down at the moment.
> >>
> >> K.C.
> >
> > the nfs/... entry was missing, so i added:
> > nfs/night_crawler.localdomain.de-jgXV7fHVA4Rbjp6DLoyPiQ@public.gmane.org
> > with the des-cbc-crc as only enc type.
> >
> > but still rpc.svcgssd fails with:
> > ERROR: GSS-API: error in gss_acquire_cred():  No credentials were
> > supplied, or the credentials were unavailable or inaccessible. - unknown
> > mech-code 0 for mech unknown
> > Unable to obtain credentials for 'nfs'
> > unable to obtain root (machine) credentials
> > do you have a keytab entry for nfs/<your.host>@<YOUR.REALM>
> > in /etc/krb5.keytab?
> 
> I think there should be more messages with "-vvv" enabled?
> Do you have /etc/gssapi_mech.conf configured for kerberos?
> 
> What distribution is this?
> 
> K.C.


Distribution: archlinux, nfs4-utils is currently unmaintained.

/etc/gssapi.conf
/usr/lib/libgssapi.so            mechglue_internal_krb5_init


oops, typo.
I added....-jgXV7fHVA4Rbjp6DLoyPiQ@public.gmane.org

Now rpc.svcgssd starts and prints: 
rpc.svcgssd -vvvf
entering pool

rpc.gssd -vvvf
beginning poll


mount -v nfs4-mount/
mount.nfs4: timeout set for Mon Jan 26 21:55:13 2009
mount.nfs4: text-based options:
'sec=krb5,clientaddr=141.x.x.x,addr=141.x.x.x'
mount.nfs4: mount(2): Connection timed out

-------------------------------------------------
Forgot to check rpc.gssd / rpc.svcgssd outputs after they started:

rpc.gssd:
handling krb5 upcall
Full hostname for 'night_crawler.localdomain.de' is 'night_crawler.localdomain.de'
Full hostname for 'wf.localdomain.de' is 'wf.localdomain.de'
Failed to find root/wf.localdomain.de-nFKzsJqY50Rbjp6DLoyPiQ@public.gmane.org in keytab FILE:/etc/krb5.keytab (null) while getting keytab entry for 'root/wf.localdomain.de-nFKzsJqY50Rbjp6DLoyPiQ@public.gmane.org'
Success getting keytab entry for 'nfs/wf.localdomain.de-nFKzsJqY50Rbjp6DLoyPiQ@public.gmane.org'
Successfully obtained machine credentials for principal 'nfs/wf.localdomain.de-nFKzsJqY50Rbjp6DLoyPiQ@public.gmane.org' stored in ccache 'FILE:/tmp/krb5cc_machine_LOCALDOMAIN.DE'
INFO: Credentials in CC 'FILE:/tmp/krb5cc_machine_LOCALDOMAIN.DE' are good until 1233064732
INFO: Credentials in CC 'FILE:/tmp/krb5cc_machine_LOCALDOMAIN.DE' are good until 1233064499
INFO: Credentials in CC 'FILE:/tmp/krb5cc_machine_LOCALDOMAIN.DE' are good until 1233064431
using FILE:/tmp/krb5cc_machine_LOCALDOMAIN.DE as credentials cache for machine creds
using gss_krb5_ccache_name to select krb5 ccache FILE:/tmp/krb5cc_machine_LOCALDOMAIN.DE
creating context using fsuid 0 (save_uid 0)
creating tcp client for server night_crawler.localdomain.de
creating context with server nfs@night_crawler.localdomain.de
DEBUG: serialize_krb5_ctx: lucid version!
prepare_krb5_rfc1964_buffer: overriding heimdal keytype (1 => 4)
prepare_krb5_rfc1964_buffer: serializing keys with enctype 4 and length 8
ERROR: GSS-API: error in gss_krb5_export_lucid_sec_context():  Miscellaneous failure (see text) - unknown mech-code 0 for mech 1 2 840 113554 1 2 2
WARN: failed to free lucid sec context
doing downcall
destroying client clnt13
destroying client clnt12



rpc.svcgssd:
entering poll
leaving poll
handling null request
sname = nfs/wf.localdomain.de-nFKzsJqY50Rbjp6DLoyPiQ@public.gmane.org
DEBUG: serialize_krb5_ctx: lucid version!
prepare_krb5_rfc1964_buffer: overriding heimdal keytype (1 => 4)
prepare_krb5_rfc1964_buffer: serializing keys with enctype 4 and length 8
ERROR: GSS-API: error in gss_krb5_export_lucid_sec_context():  Miscellaneous failure (see text) - unknown mech-code 0 for mech 1 2 840 113554 1 2 2
WARN: failed to free lucid sec context
doing downcall
mech: krb5, hndl len: 4, ctx len 85, timeout: 2147483647, uid: -1, gid: -1, num aux grps: 0:
sending null reply
writing message: \x \x6082026c06092a864886f71201020201006e82025b30820257a003020105a10302010ea20703050020000000a3820157618201533082014fa003020105a1101b0e4c4f43414c444f4d41494e2e4445a22e302ca003020101a12530231b036e66731b1c6e696768745f637261776c65722e6c6f63616c646f6d61696e2e6465a382010430820100a003020101a103020101a281f30481f04c2b703964853f2c886823dee31b4f99a03243453c068d8893ad29decc4dca456b4b9fd297587a9c4d8b734f7dedf970fc9cb7c0f572d49713b3e1b2f31002e83a0ae8fb4683410f1491e02bfb1dffc13c551e3163c439f328e0688a4ba6d5a6fd3399a909e399c04df5f0bf21b77c577cfc9eb38012373090f1b0a966205ca8b670a8c5ed06afb7be8ef01510815598fd1a03136bf3baf762bd2b044660088cf51545d248a2cbb59e4c5a67568217e57561f2b598f2ed3b0334c6aaa1ac1f377adefd29178deca3634d39fa93083c8366fdab63a265fadb09555ab9320ecf13419946cf2e95458d23099b239c34
 ce69a481e63081e3a003020101a281db0481d832f703898fe951a4c48802463772642976ec84218c543ae3149c2fa567dd6dc6fb3510cffaf5f12ec5750d937fa54502a2c2ba515606658add54557a7045faf7c82fd44281fc10e43c0e9017054cedc49b65f1f74ac9f9065a954e2b288163eaa576f82f50cfc6c573ce60aefc3454e4db465949a3527cf5c1ce7726f7d0f0efd8bff7a903b88889a46457da1bf8ad045f6e1f0337ed7d0e372f18c17a9da023db881ea002d84031056e9d569fc0fa60c82010955d91419bf7cdd7392fc69c9b3131e5153dbb4f5683c99956c82d0a323d9d8568f4b4e81b 2147483647 0 0 \x0a000000 \x607006092a864886f71201020202006f61305fa003020105a10302010fa2533051a003020101a24a044874dbcf32bdf40cb6fad7948f3f47e3b7c0e315cf292d56fd21a2deb0cb9ec65c742ca497a045e2e0f4ae0a57e837c579969176dd01a219adcc853e0dda811b05b4a62a3ecd354e0c
finished handling null request
entering poll








