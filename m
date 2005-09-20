From: Sumeet Gupta <sumeet.gupta@flextronicssoftware.com>
Subject: Re: Minor problem in nfsv3 write
Date: Tue, 20 Sep 2005 11:59:16 +0530
Message-ID: <OF9C589B26.99D803BE-ON65257082.00204954-65257082.0023A3A3@flextronicssoftware.com>
Mime-Version: 1.0
Content-Type: multipart/alternative; boundary="=_alternative 0023A39965257082_="
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EHbhY-0006gh-D2
	for nfs@lists.sourceforge.net; Mon, 19 Sep 2005 23:34:00 -0700
Received: from spark.hss.co.in ([203.145.155.21])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1EHbhT-0002sx-LR
	for nfs@lists.sourceforge.net; Mon, 19 Sep 2005 23:34:00 -0700
To: Steven <steven@void.org>, bfields@fieldses.org
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

This is a multipart message in MIME format.
--=_alternative 0023A39965257082_=
Content-Type: text/plain; charset="us-ascii"

Still the following message is coming in /var/log/messages 

Sep 20 13:56:46 rncpet31 nfs: Starting NFS services:  succeeded
Sep 20 13:56:46 rncpet31 nfs: rpc.rquotad startup succeeded
Sep 20 13:56:46 rncpet31 nfsd[2256]: nfssvc: No such device
Sep 20 13:56:46 rncpet31 nfs: rpc.nfsd startup failed
Sep 20 13:56:46 rncpet31 nfs: rpc.mountd startup succeeded



steps  I followed while upgrading my kernel from 2.4 to 2.6.9

STEP 1:
This has some useful hints on some of the changes needed.
STEP 2:
Download the latest version of module-init-tools

"module-init-tools-3.0.tar.gz" and
"modutils-2.4.21-23.src.rpm"

http://www.kernel.org/pub/linux/kernel/people/rusty/modules/module-init-tools-3.0.tar.gz
http://www.kernel.org/pub/linux/kernel/people/rusty/modules/modutils-2.4.21-23.src.rpm

STEP 3:
Install module-init-tools. This will replace depmod
[/sbin/depmod] and other tools.

        tar -zxvf module-init-tools-3.0.tar.gz
        cd module-init-tools-3.0
        ./configure --prefix=/sbin
        make
        make install
        ./generate-modprobe.conf /etc/modprobe.conf
STEP 4:
Install modutils-2.4.21-23.src.rpm. You may get warnings
about user rusty and group rusty not existing. Also, yes,
you'll have to force the install. If you don't do these steps
for both Redhat 9 and Redhat 8, you'll have problems with the
make modules_install.

        rpm -i modutils-2.4.21-23.src.rpm
        rpmbuild -bb /usr/src/redhat/SPECS/modutils.spec
        rpm -Fi /usr/src/redhat/RPMS/i386/modutils-2.4.21-23.i386.rpm
STEP 5:
Install and configure the kernel. Do NOT use the /usr/src/linux
area! Reference the README. I put my files in /home/src/kernel/

        gunzip linux-2.6.9.tar.gz tar -xvf linux-2.6.3.tar cd
        linux-2.6.9
STEP 6:
Copy the appropriate /usr/src/linux-2.4/configs
[kernel-2.4.20-i686.config, kernel-2.4.20-i686-smp.config]
to .config in whatever directory you are installing. In my
case it's /home/src/kernel/linux-2.6.9

       cp /usr/src/linux-2.4/configs/kernel-2.4.20-i686.config  \
                  /home/src/kernel/linux-2.6.3/.config

STEP 7:
Assuming you copied the appropriate kernel-2.4 config to
.config, run the following which will run through necessary
questions for the 2.6 kernel. Or, you might want to use the
config2.6-chirico...this has already been run through make
oldconfig on my system, and I've answered the necessary questions
for a general system.
               make oldconfig
STEP 8:
This is very important. Make sure you're .config has the
following in it CONFIG_EXT3_FS=y You'll run into the following
error if you leave this =m instead of =y:

pivotroot: pivot_root(/sysroot,/sysroot/initrd) failed

This is because Redhat 9.0 and 8.0 use the ext3 filesystem
for /boot ...

STEP 9:
Edit the Makefile and add changes to the Extraversion as desired.
Patches will update these values as well.

    VERSION = 2
    PATCHLEVEL = 6
    SUBLEVEL = 3
    EXTRAVERSION = -skim-ch6
STEP 10:
    make bzImage
STEP 11:
    make modules
STEP 12:
    make modules_install
STEP 13:
   make install
If you come across errors here, what version of "depmod" is
being picked up in your path?

Also, if you get a module not found, say the following:
No module aic7xxx found for kernel 2.6.x
Then, in /lib/modules/2.6.x/kernel/drivers/scsi/aic7xxx/
cp aic7xxx.ko aic7xxx.o

insmod should look for aic7xxx.ko ;but , it looks for aic7xxx.o

If you still have trouble, make the following change in the
.config

           CONFIG_BLK_DEV_SD=y
and go back to STEP 10.

You also may want to ref
kernel-2.6.3-i686-smp-chirico-aic7xxx.config
in
http://prdownloads.sourceforge.net/souptonuts/configs-0.3.tar.gz?download

STEP 14:
     mkdir /sys
STEP 15:
/etc/rc.sysinit needs to be modified. Look for the following
line:

action $"Mounting proc filesystem: " mount -n -t proc /proc /proc

and after this line enter the following:

action $"Mounting sysfs filesystem: " mount -t sysfs none /sys

Here's my /etc/rc.sysinit for reference:

http://prdownloads.sourceforge.net/souptonuts/rc.sysinit.txt?download

Be very careful at this step. Backup the /etc/rc.sysinit file.

Thomer [http://thomer.com/linux/migrate-to-2.6.html ] also added
changes to /etc/fstab. I only had to do STEP 16 below.

STEP 16:
Add the following to /etc/fstab for usb support.
    /proc/bus/usb           /proc/bus/usb           usbdevfs defaults  0 0
STEP 17 (CHECKING EVERYTHING):

Check the following:

a. The new image file should be installed on boot and there
should be sym link to it. My latest kernel is 2.6.3-skim-ch6,
and I got the "-skim-ch6" from the values I put in the Makefile,
so I see the following:

/boot
vmlinuz -> vmlinuz-2.6.3-skim-ch6
System.map -> System.map-2.6.3-skim-ch6

/boot/grub/grub.conf Should have been automatically
updated from make.

In /boot/grub/grub.conf change "default=0" to boot
with the new kernel. Here's an example of my
grub.conf:

  # grub.conf generated by anaconda
  #
  # Note that you do not have to rerun grub after making
  # NOTICE:  You have a /boot partition.  This means that
  #          all kernel and initrd paths are relative to
  #          root (hd0,2)
  #          kernel /vmlinuz-version ro root=/dev/hda6
  #          initrd /initrd-version.img
  #boot=/dev/hda
  default=0
  timeout=10
  splashimage=(hd0,2)/grub/splash.xpm.gz
  title Red Hat Linux (2.6.3-skim-ch6)
      root (hd0,2)
      kernel /vmlinuz-2.6.3-skim-ch6 ro root=LABEL=/
      initrd /initrd-2.6.3-skim-ch6.img
b. The directory /sys exists

c. You added the mount command for sys in /etc/rc.sysinit

d. CONFIG_EXT3_FS=y was used in the .config

e. Run /sbin/lsmod or cat /proc/modules to make
sure a 2.4 kernel module wasn't forgotten. Also
look at "$cat /proc/iomem"


Did I missed out something ??

do some other rpms also needs to be downloaded ??

the following command show give the results as 

[root@rncpet31 root]# rpm -q mount kernel
mount-2.11y-9
kernel-2.4.20-8

what does this means ??? why rpm -q kernel command showing  kernel-2.4.20-8 ??


Regards
Sumeet Gupta




Steven <steven@void.org>
Sent by: nfs-admin@lists.sourceforge.net
09/20/2005 06:40 AM

 
        To:     nfs@lists.sourceforge.net
        cc: 
        Subject:        [NFS] Minor problem in nfsv3 write



There is a minor bug in the way writes are handled in nfs3.  If the
client requests a write for more than 32k of data the server will only
write 32k but report that it wrote the whole amount.

This happens when nfs3svc_decode_writeargs caps the amount that can be
written to NFSSVC_MAXBLKSIZE (which is 32k), by limiting the amount that
it copies into the args object (fs/nfsd/nfs3xdr.c:375).  The amount that
is reported to the client is copied from the request packet, which is
the amount the client requested (fs/nfsd/nfs3proc.c:209) not the amount
which was written.

I think the right thing to do is adjust the amount in the request object
to the amount that will be written in the decoder. 

Following is an modified version of nfs3svc_decode_writeargs and diffs
against a 2.6.13 kernel which does this.

--Steven

int
nfs3svc_decode_writeargs(struct svc_rqst *rqstp, u32 *p,
                                        struct nfsd3_writeargs *args)
{
        unsigned int len, v, hdr;

        if (!(p = decode_fh(p, &args->fh))
         || !(p = xdr_decode_hyper(p, &args->offset)))
                return 0;

        args->count = ntohl(*p++);
        args->stable = ntohl(*p++);
        len = args->len = ntohl(*p++);

        hdr = (void*)p - rqstp->rq_arg.head[0].iov_base;
        if (rqstp->rq_arg.len < len + hdr)
                return 0;

        args->vec[0].iov_base = (void*)p;
        args->vec[0].iov_len = rqstp->rq_arg.head[0].iov_len - hdr;

        if (len > NFSSVC_MAXBLKSIZE) {
                len = NFSSVC_MAXBLKSIZE;
                /* adjust count to match the amount that will be written 
*/
                args->count = len;
        }
        v=  0;
        while (len > args->vec[v].iov_len) {
                len -= args->vec[v].iov_len;
                v++;
                args->vec[v].iov_base = 
page_address(rqstp->rq_argpages[v]);
                args->vec[v].iov_len = PAGE_SIZE;
        }
        args->vec[v].iov_len = len;
        args->vlen = v+1;

        /* args->count may be less than args->len since it is capped */
        return args->count <= args->len && args->vec[0].iov_len > 0;
}

*** fs/nfsd/nfs3xdr.c.orig               Fri Sep 16 18:02:12 2005
--- fs/nfsd/nfs3xdr.c            Mon Sep 19 17:35:22 2005
***************
*** 372,379 ****
                 args->vec[0].iov_base = (void*)p;
                 args->vec[0].iov_len = rqstp->rq_arg.head[0].iov_len - 
hdr;
 
!                if (len > NFSSVC_MAXBLKSIZE)
                                 len = NFSSVC_MAXBLKSIZE;
                 v=  0;
                 while (len > args->vec[v].iov_len) {
                                 len -= args->vec[v].iov_len;
--- 372,382 ----
                 args->vec[0].iov_base = (void*)p;
                 args->vec[0].iov_len = rqstp->rq_arg.head[0].iov_len - 
hdr;
 
!                if (len > NFSSVC_MAXBLKSIZE) {
                                 len = NFSSVC_MAXBLKSIZE;
+                                /* adjust count to match the amount that 
will be written */
+                                args->count = len;
+                }
                 v=  0;
                 while (len > args->vec[v].iov_len) {
                                 len -= args->vec[v].iov_len;
***************
*** 384,390 ****
                 args->vec[v].iov_len = len;
                 args->vlen = v+1;
 
!                return args->count == args->len && args->vec[0].iov_len > 
0;
  }
 
  int
--- 387,394 ----
                 args->vec[v].iov_len = len;
                 args->vlen = v+1;
 
!                /* args->count may be less than args->len since it is 
capped */
!                return args->count <= args->len && args->vec[0].iov_len > 
0;
  }
 
  int


-------------------------------------------------------
SF.Net email is sponsored by:
Tame your development challenges with Apache's Geronimo App Server. 
Download it for free - -and be entered to win a 42" plasma tv or your very
own Sony(tm)PSP.  Click here to play: http://sourceforge.net/geronimo.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs



--=_alternative 0023A39965257082_=
Content-Type: text/html; charset="us-ascii"


<br><font size=2 face="sans-serif">Still the following message is coming in /var/log/messages </font>
<br>
<br><font size=2 face="sans-serif">Sep 20 13:56:46 rncpet31 nfs: Starting NFS services: &nbsp;succeeded</font>
<br><font size=2 face="sans-serif">Sep 20 13:56:46 rncpet31 nfs: rpc.rquotad startup succeeded</font>
<br><font size=2 face="sans-serif">Sep 20 13:56:46 rncpet31<b> nfsd[2256]: nfssvc: No such device</b></font>
<br><font size=2 face="sans-serif">Sep 20 13:56:46 rncpet31<b> nfs: rpc.nfsd startup failed</b></font>
<br><font size=2 face="sans-serif">Sep 20 13:56:46 rncpet31 nfs: rpc.mountd startup succeeded</font>
<br>
<br>
<br>
<br><font size=2 face="sans-serif"><b>steps &nbsp;I followed while upgrading my kernel from 2.4 to 2.6.9</b></font>
<br>
<br><font size=2 face="sans-serif">STEP 1:</font>
<br><font size=2 face="sans-serif">This has some useful hints on some of the changes needed.</font>
<br><font size=2 face="sans-serif">STEP 2:</font>
<br><font size=2 face="sans-serif">Download the latest version of module-init-tools</font>
<br>
<br><font size=2 face="sans-serif">&quot;module-init-tools-3.0.tar.gz&quot; and</font>
<br><font size=2 face="sans-serif">&quot;modutils-2.4.21-23.src.rpm&quot;</font>
<br>
<br><font size=2 face="sans-serif">http://www.kernel.org/pub/linux/kernel/people/rusty/modules/module-init-tools-3.0.tar.gz</font>
<br><font size=2 face="sans-serif">http://www.kernel.org/pub/linux/kernel/people/rusty/modules/modutils-2.4.21-23.src.rpm</font>
<br>
<br><font size=2 face="sans-serif">STEP 3:</font>
<br><font size=2 face="sans-serif">Install module-init-tools. This will replace depmod</font>
<br><font size=2 face="sans-serif">[/sbin/depmod] and other tools.</font>
<br>
<br><font size=2 face="sans-serif">&nbsp; &nbsp; &nbsp; &nbsp; tar -zxvf module-init-tools-3.0.tar.gz</font>
<br><font size=2 face="sans-serif">&nbsp; &nbsp; &nbsp; &nbsp; cd module-init-tools-3.0</font>
<br><font size=2 face="sans-serif">&nbsp; &nbsp; &nbsp; &nbsp; ./configure --prefix=/sbin</font>
<br><font size=2 face="sans-serif">&nbsp; &nbsp; &nbsp; &nbsp; make</font>
<br><font size=2 face="sans-serif">&nbsp; &nbsp; &nbsp; &nbsp; make install</font>
<br><font size=2 face="sans-serif">&nbsp; &nbsp; &nbsp; &nbsp; ./generate-modprobe.conf /etc/modprobe.conf</font>
<br><font size=2 face="sans-serif">STEP 4:</font>
<br><font size=2 face="sans-serif">Install modutils-2.4.21-23.src.rpm. You may get warnings</font>
<br><font size=2 face="sans-serif">about user rusty and group rusty not existing. Also, yes,</font>
<br><font size=2 face="sans-serif">you'll have to force the install. If you don't do these steps</font>
<br><font size=2 face="sans-serif">for both Redhat 9 and Redhat 8, you'll have problems with the</font>
<br><font size=2 face="sans-serif">make modules_install.</font>
<br>
<br><font size=2 face="sans-serif">&nbsp; &nbsp; &nbsp; &nbsp; rpm -i modutils-2.4.21-23.src.rpm</font>
<br><font size=2 face="sans-serif">&nbsp; &nbsp; &nbsp; &nbsp; rpmbuild -bb /usr/src/redhat/SPECS/modutils.spec</font>
<br><font size=2 face="sans-serif">&nbsp; &nbsp; &nbsp; &nbsp; rpm -Fi /usr/src/redhat/RPMS/i386/modutils-2.4.21-23.i386.rpm</font>
<br><font size=2 face="sans-serif">STEP 5:</font>
<br><font size=2 face="sans-serif">Install and configure the kernel. Do NOT use the /usr/src/linux</font>
<br><font size=2 face="sans-serif">area! Reference the README. I put my files in /home/src/kernel/</font>
<br>
<br><font size=2 face="sans-serif">&nbsp; &nbsp; &nbsp; &nbsp; gunzip linux-2.6.9.tar.gz tar -xvf linux-2.6.3.tar cd</font>
<br><font size=2 face="sans-serif">&nbsp; &nbsp; &nbsp; &nbsp; linux-2.6.9</font>
<br><font size=2 face="sans-serif">STEP 6:</font>
<br><font size=2 face="sans-serif">Copy the appropriate /usr/src/linux-2.4/configs</font>
<br><font size=2 face="sans-serif">[kernel-2.4.20-i686.config, kernel-2.4.20-i686-smp.config]</font>
<br><font size=2 face="sans-serif">to .config in whatever directory you are installing. In my</font>
<br><font size=2 face="sans-serif">case it's /home/src/kernel/linux-2.6.9</font>
<br>
<br><font size=2 face="sans-serif">&nbsp; &nbsp; &nbsp; &nbsp;cp /usr/src/linux-2.4/configs/kernel-2.4.20-i686.config &nbsp;\</font>
<br><font size=2 face="sans-serif">&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; /home/src/kernel/linux-2.6.3/.config</font>
<br>
<br><font size=2 face="sans-serif">STEP 7:</font>
<br><font size=2 face="sans-serif">Assuming you copied the appropriate kernel-2.4 config to</font>
<br><font size=2 face="sans-serif">.config, run the following which will run through necessary</font>
<br><font size=2 face="sans-serif">questions for the 2.6 kernel. Or, you might want to use the</font>
<br><font size=2 face="sans-serif">config2.6-chirico...this has already been run through make</font>
<br><font size=2 face="sans-serif">oldconfig on my system, and I've answered the necessary questions</font>
<br><font size=2 face="sans-serif">for a general system.</font>
<br><font size=2 face="sans-serif">&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;make oldconfig</font>
<br><font size=2 face="sans-serif">STEP 8:</font>
<br><font size=2 face="sans-serif">This is very important. Make sure you're .config has the</font>
<br><font size=2 face="sans-serif">following in it CONFIG_EXT3_FS=y You'll run into the following</font>
<br><font size=2 face="sans-serif">error if you leave this =m instead of =y:</font>
<br>
<br><font size=2 face="sans-serif">pivotroot: pivot_root(/sysroot,/sysroot/initrd) failed</font>
<br>
<br><font size=2 face="sans-serif">This is because Redhat 9.0 and 8.0 use the ext3 filesystem</font>
<br><font size=2 face="sans-serif">for /boot ...</font>
<br>
<br><font size=2 face="sans-serif">STEP 9:</font>
<br><font size=2 face="sans-serif">Edit the Makefile and add changes to the Extraversion as desired.</font>
<br><font size=2 face="sans-serif">Patches will update these values as well.</font>
<br>
<br><font size=2 face="sans-serif">&nbsp; &nbsp; VERSION = 2</font>
<br><font size=2 face="sans-serif">&nbsp; &nbsp; PATCHLEVEL = 6</font>
<br><font size=2 face="sans-serif">&nbsp; &nbsp; SUBLEVEL = 3</font>
<br><font size=2 face="sans-serif">&nbsp; &nbsp; EXTRAVERSION = -skim-ch6</font>
<br><font size=2 face="sans-serif">STEP 10:</font>
<br><font size=2 face="sans-serif">&nbsp; &nbsp; make bzImage</font>
<br><font size=2 face="sans-serif">STEP 11:</font>
<br><font size=2 face="sans-serif">&nbsp; &nbsp; make modules</font>
<br><font size=2 face="sans-serif">STEP 12:</font>
<br><font size=2 face="sans-serif">&nbsp; &nbsp; make modules_install</font>
<br><font size=2 face="sans-serif">STEP 13:</font>
<br><font size=2 face="sans-serif">&nbsp; &nbsp;make install</font>
<br><font size=2 face="sans-serif">If you come across errors here, what version of &quot;depmod&quot; is</font>
<br><font size=2 face="sans-serif">being picked up in your path?</font>
<br>
<br><font size=2 face="sans-serif">Also, if you get a module not found, say the following:</font>
<br><font size=2 face="sans-serif">No module aic7xxx found for kernel 2.6.x</font>
<br><font size=2 face="sans-serif">Then, in /lib/modules/2.6.x/kernel/drivers/scsi/aic7xxx/</font>
<br><font size=2 face="sans-serif">cp aic7xxx.ko aic7xxx.o</font>
<br>
<br><font size=2 face="sans-serif">insmod should look for aic7xxx.ko ;but , it looks for aic7xxx.o</font>
<br>
<br><font size=2 face="sans-serif">If you still have trouble, make the following change in the</font>
<br><font size=2 face="sans-serif">.config</font>
<br>
<br><font size=2 face="sans-serif">&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;CONFIG_BLK_DEV_SD=y</font>
<br><font size=2 face="sans-serif">and go back to STEP 10.</font>
<br>
<br><font size=2 face="sans-serif">You also may want to ref</font>
<br><font size=2 face="sans-serif">kernel-2.6.3-i686-smp-chirico-aic7xxx.config</font>
<br><font size=2 face="sans-serif">in</font>
<br><font size=2 face="sans-serif">http://prdownloads.sourceforge.net/souptonuts/configs-0.3.tar.gz?download</font>
<br>
<br><font size=2 face="sans-serif">STEP 14:</font>
<br><font size=2 face="sans-serif">&nbsp; &nbsp; &nbsp;mkdir /sys</font>
<br><font size=2 face="sans-serif">STEP 15:</font>
<br><font size=2 face="sans-serif">/etc/rc.sysinit needs to be modified. Look for the following</font>
<br><font size=2 face="sans-serif">line:</font>
<br>
<br><font size=2 face="sans-serif">action $&quot;Mounting proc filesystem: &quot; mount -n -t proc /proc /proc</font>
<br>
<br><font size=2 face="sans-serif">and after this line enter the following:</font>
<br>
<br><font size=2 face="sans-serif">action $&quot;Mounting sysfs filesystem: &quot; mount -t sysfs none /sys</font>
<br>
<br><font size=2 face="sans-serif">Here's my /etc/rc.sysinit for reference:</font>
<br>
<br><font size=2 face="sans-serif">http://prdownloads.sourceforge.net/souptonuts/rc.sysinit.txt?download</font>
<br>
<br><font size=2 face="sans-serif">Be very careful at this step. Backup the /etc/rc.sysinit file.</font>
<br>
<br><font size=2 face="sans-serif">Thomer [http://thomer.com/linux/migrate-to-2.6.html ] also added</font>
<br><font size=2 face="sans-serif">changes to /etc/fstab. I only had to do STEP 16 below.</font>
<br>
<br><font size=2 face="sans-serif">STEP 16:</font>
<br><font size=2 face="sans-serif">Add the following to /etc/fstab for usb support.</font>
<br><font size=2 face="sans-serif">&nbsp; &nbsp; /proc/bus/usb &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; /proc/bus/usb &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; usbdevfs defaults &nbsp; &nbsp; &nbsp; 0 0</font>
<br><font size=2 face="sans-serif">STEP 17 (CHECKING EVERYTHING):</font>
<br>
<br><font size=2 face="sans-serif">Check the following:</font>
<br>
<br><font size=2 face="sans-serif">a. The new image file should be installed on boot and there</font>
<br><font size=2 face="sans-serif">should be sym link to it. My latest kernel is 2.6.3-skim-ch6,</font>
<br><font size=2 face="sans-serif">and I got the &quot;-skim-ch6&quot; from the values I put in the Makefile,</font>
<br><font size=2 face="sans-serif">so I see the following:</font>
<br>
<br><font size=2 face="sans-serif">/boot</font>
<br><font size=2 face="sans-serif">vmlinuz -&gt; vmlinuz-2.6.3-skim-ch6</font>
<br><font size=2 face="sans-serif">System.map -&gt; System.map-2.6.3-skim-ch6</font>
<br>
<br><font size=2 face="sans-serif">/boot/grub/grub.conf Should have been automatically</font>
<br><font size=2 face="sans-serif">updated from make.</font>
<br>
<br><font size=2 face="sans-serif">In /boot/grub/grub.conf change &quot;default=0&quot; to boot</font>
<br><font size=2 face="sans-serif">with the new kernel. Here's an example of my</font>
<br><font size=2 face="sans-serif">grub.conf:</font>
<br>
<br><font size=2 face="sans-serif">&nbsp; # grub.conf generated by anaconda</font>
<br><font size=2 face="sans-serif">&nbsp; #</font>
<br><font size=2 face="sans-serif">&nbsp; # Note that you do not have to rerun grub after making</font>
<br><font size=2 face="sans-serif">&nbsp; # NOTICE: &nbsp;You have a /boot partition. &nbsp;This means that</font>
<br><font size=2 face="sans-serif">&nbsp; # &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;all kernel and initrd paths are relative to</font>
<br><font size=2 face="sans-serif">&nbsp; # &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;root (hd0,2)</font>
<br><font size=2 face="sans-serif">&nbsp; # &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;kernel /vmlinuz-version ro root=/dev/hda6</font>
<br><font size=2 face="sans-serif">&nbsp; # &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;initrd /initrd-version.img</font>
<br><font size=2 face="sans-serif">&nbsp; #boot=/dev/hda</font>
<br><font size=2 face="sans-serif">&nbsp; default=0</font>
<br><font size=2 face="sans-serif">&nbsp; timeout=10</font>
<br><font size=2 face="sans-serif">&nbsp; splashimage=(hd0,2)/grub/splash.xpm.gz</font>
<br><font size=2 face="sans-serif">&nbsp; title Red Hat Linux (2.6.3-skim-ch6)</font>
<br><font size=2 face="sans-serif">&nbsp; &nbsp; &nbsp; root (hd0,2)</font>
<br><font size=2 face="sans-serif">&nbsp; &nbsp; &nbsp; kernel /vmlinuz-2.6.3-skim-ch6 ro root=LABEL=/</font>
<br><font size=2 face="sans-serif">&nbsp; &nbsp; &nbsp; initrd /initrd-2.6.3-skim-ch6.img</font>
<br><font size=2 face="sans-serif">b. The directory /sys exists</font>
<br>
<br><font size=2 face="sans-serif">c. You added the mount command for sys in /etc/rc.sysinit</font>
<br>
<br><font size=2 face="sans-serif">d. CONFIG_EXT3_FS=y was used in the .config</font>
<br>
<br><font size=2 face="sans-serif">e. Run /sbin/lsmod or cat /proc/modules to make</font>
<br><font size=2 face="sans-serif">sure a 2.4 kernel module wasn't forgotten. Also</font>
<br><font size=2 face="sans-serif">look at &quot;$cat /proc/iomem&quot;</font>
<br>
<br>
<br><font size=2 face="sans-serif"><b>Did I missed out something ??</b></font>
<br>
<br><font size=2 face="sans-serif"><b>do some other rpms also needs to be downloaded ??</b></font>
<br>
<br><font size=2 face="sans-serif"><b>the following command show give the results as </b></font>
<br>
<br><font size=2 face="sans-serif"><b>[root@rncpet31 root]# rpm -q mount kernel</b></font>
<br><font size=2 face="sans-serif"><b>mount-2.11y-9</b></font>
<br><font size=2 face="sans-serif"><b>kernel-2.4.20-8</b></font>
<br>
<br><font size=2 face="sans-serif">what does this means ??? why rpm -q kernel command showing &nbsp;<b>kernel-2.4.20-8</b> ??</font>
<br>
<br><font size=2 face="sans-serif"><br>
Regards<br>
Sumeet Gupta</font>
<br>
<br>
<br>
<table width=100%>
<tr valign=top>
<td>
<td><font size=1 face="sans-serif"><b>Steven &lt;steven@void.org&gt;</b></font>
<br><font size=1 face="sans-serif">Sent by: nfs-admin@lists.sourceforge.net</font>
<p><font size=1 face="sans-serif">09/20/2005 06:40 AM</font>
<br>
<td><font size=1 face="Arial">&nbsp; &nbsp; &nbsp; &nbsp; </font>
<br><font size=1 face="sans-serif">&nbsp; &nbsp; &nbsp; &nbsp; To: &nbsp; &nbsp; &nbsp; &nbsp;nfs@lists.sourceforge.net</font>
<br><font size=1 face="sans-serif">&nbsp; &nbsp; &nbsp; &nbsp; cc: &nbsp; &nbsp; &nbsp; &nbsp;</font>
<br><font size=1 face="sans-serif">&nbsp; &nbsp; &nbsp; &nbsp; Subject: &nbsp; &nbsp; &nbsp; &nbsp;[NFS] Minor problem in nfsv3 write</font></table>
<br>
<br>
<br><font size=2 face="Courier New"><br>
There is a minor bug in the way writes are handled in nfs3. &nbsp;If the<br>
client requests a write for more than 32k of data the server will only<br>
write 32k but report that it wrote the whole amount.<br>
<br>
This happens when nfs3svc_decode_writeargs caps the amount that can be<br>
written to NFSSVC_MAXBLKSIZE (which is 32k), by limiting the amount that<br>
it copies into the args object (fs/nfsd/nfs3xdr.c:375). &nbsp;The amount that<br>
is reported to the client is copied from the request packet, which is<br>
the amount the client requested (fs/nfsd/nfs3proc.c:209) not the amount<br>
which was written.<br>
<br>
I think the right thing to do is adjust the amount in the request object<br>
to the amount that will be written in the decoder. <br>
<br>
Following is an modified version of nfs3svc_decode_writeargs and diffs<br>
against a 2.6.13 kernel which does this.<br>
<br>
--Steven<br>
<br>
int<br>
nfs3svc_decode_writeargs(struct svc_rqst *rqstp, u32 *p,<br>
 &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;struct nfsd3_writeargs *args)<br>
{<br>
 &nbsp; &nbsp; &nbsp; &nbsp;unsigned int len, v, hdr;<br>
<br>
 &nbsp; &nbsp; &nbsp; &nbsp;if (!(p = decode_fh(p, &amp;args-&gt;fh))<br>
 &nbsp; &nbsp; &nbsp; &nbsp; || !(p = xdr_decode_hyper(p, &amp;args-&gt;offset)))<br>
 &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;return 0;<br>
<br>
 &nbsp; &nbsp; &nbsp; &nbsp;args-&gt;count = ntohl(*p++);<br>
 &nbsp; &nbsp; &nbsp; &nbsp;args-&gt;stable = ntohl(*p++);<br>
 &nbsp; &nbsp; &nbsp; &nbsp;len = args-&gt;len = ntohl(*p++);<br>
<br>
 &nbsp; &nbsp; &nbsp; &nbsp;hdr = (void*)p - rqstp-&gt;rq_arg.head[0].iov_base;<br>
 &nbsp; &nbsp; &nbsp; &nbsp;if (rqstp-&gt;rq_arg.len &lt; len + hdr)<br>
 &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;return 0;<br>
<br>
 &nbsp; &nbsp; &nbsp; &nbsp;args-&gt;vec[0].iov_base = (void*)p;<br>
 &nbsp; &nbsp; &nbsp; &nbsp;args-&gt;vec[0].iov_len = rqstp-&gt;rq_arg.head[0].iov_len - hdr;<br>
<br>
 &nbsp; &nbsp; &nbsp; &nbsp;if (len &gt; NFSSVC_MAXBLKSIZE) {<br>
 &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;len = NFSSVC_MAXBLKSIZE;<br>
 &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;/* adjust count to match the amount that will be written */<br>
 &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;args-&gt;count = len;<br>
 &nbsp; &nbsp; &nbsp; &nbsp;}<br>
 &nbsp; &nbsp; &nbsp; &nbsp;v= &nbsp;0;<br>
 &nbsp; &nbsp; &nbsp; &nbsp;while (len &gt; args-&gt;vec[v].iov_len) {<br>
 &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;len -= args-&gt;vec[v].iov_len;<br>
 &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;v++;<br>
 &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;args-&gt;vec[v].iov_base = page_address(rqstp-&gt;rq_argpages[v]);<br>
 &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;args-&gt;vec[v].iov_len = PAGE_SIZE;<br>
 &nbsp; &nbsp; &nbsp; &nbsp;}<br>
 &nbsp; &nbsp; &nbsp; &nbsp;args-&gt;vec[v].iov_len = len;<br>
 &nbsp; &nbsp; &nbsp; &nbsp;args-&gt;vlen = v+1;<br>
<br>
 &nbsp; &nbsp; &nbsp; &nbsp;/* args-&gt;count may be less than args-&gt;len since it is capped */<br>
 &nbsp; &nbsp; &nbsp; &nbsp;return args-&gt;count &lt;= args-&gt;len &amp;&amp; args-&gt;vec[0].iov_len &gt; 0;<br>
}<br>
<br>
*** fs/nfsd/nfs3xdr.c.orig &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; Fri Sep 16 18:02:12 2005<br>
--- fs/nfsd/nfs3xdr.c &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; Mon Sep 19 17:35:22 2005<br>
***************<br>
*** 372,379 ****<br>
 &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; args-&gt;vec[0].iov_base = (void*)p;<br>
 &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; args-&gt;vec[0].iov_len = rqstp-&gt;rq_arg.head[0].iov_len - hdr;<br>
 &nbsp;<br>
! &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;if (len &gt; NFSSVC_MAXBLKSIZE)<br>
 &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;len = NFSSVC_MAXBLKSIZE;<br>
 &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; v= &nbsp;0;<br>
 &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; while (len &gt; args-&gt;vec[v].iov_len) {<br>
 &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;len -= args-&gt;vec[v].iov_len;<br>
--- 372,382 ----<br>
 &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; args-&gt;vec[0].iov_base = (void*)p;<br>
 &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; args-&gt;vec[0].iov_len = rqstp-&gt;rq_arg.head[0].iov_len - hdr;<br>
 &nbsp;<br>
! &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;if (len &gt; NFSSVC_MAXBLKSIZE) {<br>
 &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;len = NFSSVC_MAXBLKSIZE;<br>
+ &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; /* adjust count to match the amount that will be written */<br>
+ &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; args-&gt;count = len;<br>
+ &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;}<br>
 &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; v= &nbsp;0;<br>
 &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; while (len &gt; args-&gt;vec[v].iov_len) {<br>
 &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;len -= args-&gt;vec[v].iov_len;<br>
***************<br>
*** 384,390 ****<br>
 &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; args-&gt;vec[v].iov_len = len;<br>
 &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; args-&gt;vlen = v+1;<br>
 &nbsp;<br>
! &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;return args-&gt;count == args-&gt;len &amp;&amp; args-&gt;vec[0].iov_len &gt; 0;<br>
 &nbsp;}<br>
 &nbsp;<br>
 &nbsp;int<br>
--- 387,394 ----<br>
 &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; args-&gt;vec[v].iov_len = len;</font>
<br><font size=2 face="Courier New">&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;args-&gt;vlen = v+1;<br>
 &nbsp;<br>
! &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;/* args-&gt;count may be less than args-&gt;len since it is capped */<br>
! &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;return args-&gt;count &lt;= args-&gt;len &amp;&amp; args-&gt;vec[0].iov_len &gt; 0;<br>
 &nbsp;}<br>
 &nbsp;<br>
 &nbsp;int<br>
<br>
<br>
-------------------------------------------------------<br>
SF.Net email is sponsored by:<br>
Tame your development challenges with Apache's Geronimo App Server. <br>
Download it for free - -and be entered to win a 42&quot; plasma tv or your very<br>
own Sony(tm)PSP. &nbsp;Click here to play: http://sourceforge.net/geronimo.php<br>
_______________________________________________<br>
NFS maillist &nbsp;- &nbsp;NFS@lists.sourceforge.net<br>
https://lists.sourceforge.net/lists/listinfo/nfs<br>
</font>
<br>
<br>
--=_alternative 0023A39965257082_=--


-------------------------------------------------------
SF.Net email is sponsored by:
Tame your development challenges with Apache's Geronimo App Server. 
Download it for free - -and be entered to win a 42" plasma tv or your very
own Sony(tm)PSP.  Click here to play: http://sourceforge.net/geronimo.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
