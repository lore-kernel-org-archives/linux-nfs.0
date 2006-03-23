From: "Kevin Coffman" <kwc@citi.umich.edu>
Subject: Re: NFSv4 problem?(chown(1) process hang)
Date: Thu, 23 Mar 2006 18:22:42 -0500
Message-ID: <4d569c330603231522h6d09449etc9553a35512628c4@mail.gmail.com>
References: <20060316120750.76054181.s-sagawa@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="----=_Part_4808_5021322.1143156162956"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FMZ8g-0005hQ-QJ
	for nfs@lists.sourceforge.net; Thu, 23 Mar 2006 15:22:46 -0800
Received: from [64.233.182.185] (helo=nproxy.gmail.com)
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1FMZ8f-0007Jm-5v
	for nfs@lists.sourceforge.net; Thu, 23 Mar 2006 15:22:46 -0800
Received: by nproxy.gmail.com with SMTP id i2so351482nfe
        for <nfs@lists.sourceforge.net>; Thu, 23 Mar 2006 15:22:43 -0800 (PST)
To: "Shunichi Sagawa" <s-sagawa@jp.fujitsu.com>
In-Reply-To: <20060316120750.76054181.s-sagawa@jp.fujitsu.com>
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

------=_Part_4808_5021322.1143156162956
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

The problem appears to be an error in our code that only exhibits the
problem when used in combination with libevent-1.0b.  When used with
other versions of libevent, the problem doesn't appear...

(Hopefully) attached is the patch.


On 3/15/06, Shunichi Sagawa <s-sagawa@jp.fujitsu.com> wrote:
> Hello,
>
> In the NFS access operation,
> "chown guest.guest file" causes the process hang.
>
>
> [NG pattern]---------------------------------------------------------
>    <server kernel-2.6.9>
>    1. System startup
>
>    # chkconfig --list | egrep "nfs|rpcidmap"
>    nfs             0:off   1:off   2:on    3:on    4:on    5:on    6:off
>    rpcidmapd       0:off   1:off   2:off   3:on    4:on    5:on    6:off
>    nfslock         0:off   1:off   2:off   3:on    4:on    5:on    6:off
>    #
>    # cat /etc/exports
>    /work *(rw,sync,no_root_squash,fsid=3D0)
>    #
>    # ls -ld /work
>    drwxr-xr-x  3 root root 4096 Mar 16 13:22 /work
>    #
>    # grep guest /etc/passwd
>    guest:x:501:501::/home/guest:/bin/bash
>    #
>    # cat /etc/idmapd.conf
>    [General]
>
>    Verbosity =3D 0
>    Pipefs-Directory =3D /var/lib/nfs/rpc_pipefs
>    Domain =3D localdomain
>
>    [Mapping]
>
>    Nobody-User =3D nobody
>    Nobody-Group =3D nobody
>
>    [Translation]
>    Method =3D nsswitch
>    #
>
>    <client kernel-2.6.9>
>    1. System startup
>
>    # showmount -e nfsserver
>    Export list for nfsserver:
>    /work *
>    #
>    # grep guest /etc/passwd
>    guest:x:501:501::/home/guest:/bin/bash
>    #
>    # mount -t nfs4 nfsserver:/ /mnt/nfs
>    # df
>    Filesystem           1K-blocks      Used Available Use% Mounted on
>    /dev/hda2             10080520   8027400   1541052  84% /
>    /dev/hda1               101086     24234     71633  26% /boot
>    none                    517932         0    517932   0% /dev/shm
>    /dev/hda5              4814936   1847656   2722692  41% /work
>    nfsserver:/            1027776      1280    974272   1% /mnt/nfs
>    # cd /mnt/nfs
>    # ls -l hogehoge
>    -rw-r--r--  1 root root 9 Mar 16  2006 hogehoge
>    # chown guest.guest hogehoge
>    hang.
>
> [OK pattern]-----------------------------------------------------------
>    <server>
>    1. System startup
>    2. /etc/init.d/rpcidmapd restart
>    :
>    :
>    It is the same as the operation of mentioning above.
>
>
> This problem doesn't occur if rpcidmapd is restart.
> Is it a problem of my setting?
> Or, NFSv4 problem?
>
> Best Regards,
> Sagawa.
>
>
> -------------------------------------------------------
> This SF.Net email is sponsored by xPML, a groundbreaking scripting langua=
ge
> that extends applications into web and mobile media. Attend the live webc=
ast
> and join the prime developer group breaking into this new coding territor=
y!
> http://sel.as-us.falkag.net/sel?cmd=3Dlnk&kid=3D110944&bid=3D241720&dat=
=3D121642
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs
>
>

------=_Part_4808_5021322.1143156162956
Content-Type: text/x-patch; name="idmapd_reorder_close_del.patch"
Content-Transfer-Encoding: base64
Content-Disposition: attachment; filename="idmapd_reorder_close_del.patch"
X-Attachment-Id: f_el5pmamf

CkZyb206IEtldmluIENvZmZtYW4gPGt3Y0BjaXRpLnVtaWNoLmVkdT4KCkRlbGV0ZSBldmVudCBw
cm9jZXNzaW5nIGZvciBhIGZpbGUgZGVzY3JpcHRvciBiZWZvcmUgY2xvc2luZyBpdC4KVGhpcyB3
YXMgY2F1c2luZyBoYW5ncyB3aGVuIHVzZWQgaW4gY29tYmluYXRpb24gd2l0aCBsaWJldmVudC0x
LjBiLgoKCi0tLQoKIG5mcy11dGlscy0xLjAuOC1yYzIta3djL3V0aWxzL2lkbWFwZC9pZG1hcGQu
YyB8ICAgIDQgKystLQogMSBmaWxlcyBjaGFuZ2VkLCAyIGluc2VydGlvbnMoKyksIDIgZGVsZXRp
b25zKC0pCgpkaWZmIC1wdU4gdXRpbHMvaWRtYXBkL2lkbWFwZC5jfmlkbWFwZF9yZW9yZGVyX2Ns
b3NlX2RlbCB1dGlscy9pZG1hcGQvaWRtYXBkLmMKLS0tIG5mcy11dGlscy0xLjAuOC1yYzIvdXRp
bHMvaWRtYXBkL2lkbWFwZC5jfmlkbWFwZF9yZW9yZGVyX2Nsb3NlX2RlbAkyMDA2LTAzLTIzIDE3
OjUwOjExLjA4MzM1MzAwMCAtMDUwMAorKysgbmZzLXV0aWxzLTEuMC44LXJjMi1rd2MvdXRpbHMv
aWRtYXBkL2lkbWFwZC5jCTIwMDYtMDMtMjMgMTc6NTA6NTIuNzU0NDExMDAwIC0wNTAwCkBAIC02
ODgsMTAgKzY4OCwxMCBAQCBuZnNkcmVvcGVuX29uZShzdHJ1Y3QgaWRtYXBfY2xpZW50ICppYykK
IAkJaWRtYXBkX3dhcm54KCJSZU9wZW5pbmcgJXMiLCBpYy0+aWNfcGF0aCk7CiAKIAlpZiAoKGZk
ID0gb3BlbihpYy0+aWNfcGF0aCwgT19SRFdSLCAwKSkgIT0gLTEpIHsKLQkJaWYgKGljLT5pY19m
ZCAhPSAtMSkKLQkJCWNsb3NlKGljLT5pY19mZCk7CiAJCWlmICgoaWMtPmljX2V2ZW50LmV2X2Zs
YWdzICYgRVZMSVNUX0lOSVQpKQogCQkJZXZlbnRfZGVsKCZpYy0+aWNfZXZlbnQpOworCQlpZiAo
aWMtPmljX2ZkICE9IC0xKQorCQkJY2xvc2UoaWMtPmljX2ZkKTsKIAogCQlpYy0+aWNfZXZlbnQu
ZXZfZmQgPSBpYy0+aWNfZmQgPSBmZDsKIAkJZXZlbnRfc2V0KCZpYy0+aWNfZXZlbnQsIGljLT5p
Y19mZCwgRVZfUkVBRCwgbmZzZGNiLCBpYyk7CgpfCg==
------=_Part_4808_5021322.1143156162956--


-------------------------------------------------------
This SF.Net email is sponsored by xPML, a groundbreaking scripting language
that extends applications into web and mobile media. Attend the live webcast
and join the prime developer group breaking into this new coding territory!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=110944&bid=241720&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
