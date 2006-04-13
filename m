From: "Christopher Smith" <csmithere@gmail.com>
Subject: NFSv3/4 and Kerberos.
Date: Thu, 13 Apr 2006 14:47:03 -0400
Message-ID: <2b585fc90604131147t3ffa7abemc9f50f76a7a0d3a6@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="----=_Part_31452_2394308.1144954023327"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FU6qP-0000KJ-09
	for nfs@lists.sourceforge.net; Thu, 13 Apr 2006 11:47:05 -0700
Received: from pproxy.gmail.com ([64.233.166.181])
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1FU6qO-0001fs-Jl
	for nfs@lists.sourceforge.net; Thu, 13 Apr 2006 11:47:05 -0700
Received: by pproxy.gmail.com with SMTP id i49so2040042pye
        for <nfs@lists.sourceforge.net>; Thu, 13 Apr 2006 11:47:03 -0700 (PDT)
To: nfs@lists.sourceforge.net
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

------=_Part_31452_2394308.1144954023327
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

Folks--

I'm working on doing some testing of NFSv3 and NFSv4, and I'm running
into the following error (shown from rpc.gssd -vvv -f):

rpcsec_gss: xdr_rpc_gss_init_args: encode success (token 0x9e7b550:531)
rpcsec_gss: in authgss_refresh()
rpcsec_gss: gss_init_sec_context: A token was invalid - No error
rpcsec_gss: in authgss_destroy()
rpcsec_gss: in authgss_destroy_context()
WARNING: Failed to create krb5 context for user with uid 0 for server
cmsmith-ntap.hq.example.com

The system I'm working with is:

RHEL4u3, x86 (fully updated)
uname -r: 2.6.9-34.EL
nfs-utils-1.0.6-65.EL4

I've attached 4 files as well:

1. output of klist -ae
2. my krb5.conf file
3. rpc.gssd -vvvf (full output)
4. tcpdump -s host cmsmith-ntap

Any ideas?  Please let me know if I should provide further
information.  A useful data point is that the behavior is exactly the
same for both v3 and v4 (aka, same error is generated).

Best,
CMS
--
Christopher M. Smith
csmithere@gmail.com

------=_Part_31452_2394308.1144954023327
Content-Type: application/octet-stream; name=krb5.conf
Content-Transfer-Encoding: 7bit
X-Attachment-Id: f_157xpj8
Content-Disposition: attachment; filename="krb5.conf"

[logging]
 default = FILE:/var/log/krb5libs.log
 kdc = FILE:/var/log/krb5kdc.log
 admin_server = FILE:/var/log/kadmind.log

[libdefaults]
 default_realm = HQ.EXAMPLE.COM
 dns_lookup_realm = true
 dns_lookup_kdc = true

[realms]
 HQ.EXAMPLE.COM = {
  kdc = katana.hq.example.com:88
  admin_server = katana.hq.example.com:749
  default_domain = hq.example.com
 }

[domain_realm]
 .hq.example.com = HQ.EXAMPLE.COM
 hq.example.com = HQ.EXAMPLE.COM

[kdc]
 profile = /var/kerberos/krb5kdc/kdc.conf

[appdefaults]
 pam = {
   debug = false
   ticket_lifetime = 36000
   renew_lifetime = 36000
   forwardable = true
   krb4_convert = false
 }

------=_Part_31452_2394308.1144954023327
Content-Type: application/octet-stream; name=klist
Content-Transfer-Encoding: 7bit
X-Attachment-Id: f_157y786
Content-Disposition: attachment; filename="klist"

[root@katana ~]# klist -ke
Keytab name: FILE:/etc/krb5.keytab
KVNO Principal
---- --------------------------------------------------------------------------
   3 nfs/cmsmith-ntap.hq.example.com@HQ.EXAMPLE.COM (DES cbc mode with CRC-32) 
   3 nfs/katana.hq.example.com@HQ.EXAMPLE.COM (DES cbc mode with CRC-32) 
[root@katana ~]# 


------=_Part_31452_2394308.1144954023327
Content-Type: application/octet-stream; name=rpc.gssd
Content-Transfer-Encoding: 7bit
X-Attachment-Id: f_157y8nd
Content-Disposition: attachment; filename="rpc.gssd"

Using keytab file '/etc/krb5.keytab'
Processing keytab entry for principal 'nfs/cmsmith-ntap.hq.example.com@HQ.EXAMPLE.COM'
We will use this entry (nfs/cmsmith-ntap.hq.example.com@HQ.EXAMPLE.COM)
Processing keytab entry for principal 'nfs/katana.hq.example.com@HQ.EXAMPLE.COM'
We will NOT use this entry (nfs/katana.hq.example.com@HQ.EXAMPLE.COM)
Using (machine) credentials cache: 'FILE:/tmp/krb5cc_machine_HQ.EXAMPLE.COM'
processing client list
processing client list
processing client list
handling krb5 upcall
Using keytab file '/etc/krb5.keytab'
INFO: Credentials in CC 'FILE:/tmp/krb5cc_machine_HQ.EXAMPLE.COM' are good until 1145037107
using FILE:/tmp/krb5cc_machine_HQ.EXAMPLE.COM as credentials cache for machine creds
creating context using euid 0 (save_uid 0)
creating tcp client for server cmsmith-ntap.hq.example.com
creating context with server nfs@cmsmith-ntap.hq.example.com
rpcsec_gss: in authgss_create_default()
WARNING: unable to locate function krb5_gss_internal_release_oid in krb5 mechanism library: there will be problems if multiple mechanisms are used!
rpcsec_gss: in authgss_create()
rpcsec_gss: in authgss_refresh()
rpcsec_gss: in authgss_marshal()
rpcsec_gss: xdr_rpc_gss_cred: encode success (v 1, proc 1, seq 0, svc 1, ctx (nil):0)
rpcsec_gss: xdr_rpc_gss_init_args: encode success (token 0x9e7deb8:531)
rpcsec_gss: in authgss_refresh()
rpcsec_gss: gss_init_sec_context: A token was invalid - No error
rpcsec_gss: in authgss_destroy()
rpcsec_gss: in authgss_destroy_context()
WARNING: Failed to create krb5 context for user with uid 0 for server cmsmith-ntap.hq.example.com
WARNING: Failed to create krb5 context for user with uid 0 with credentials cache FILE:/tmp/krb5cc_machine_HQ.EXAMPLE.COM for server cmsmith-ntap.hq.example.com
WARNING: Failed to create krb5 context for user with uid 0 with any credentials cache for server cmsmith-ntap.hq.example.com
doing error downcall
handling krb5 upcall
Using keytab file '/etc/krb5.keytab'
INFO: Credentials in CC 'FILE:/tmp/krb5cc_machine_HQ.EXAMPLE.COM' are good until 1145037107
using FILE:/tmp/krb5cc_machine_HQ.EXAMPLE.COM as credentials cache for machine creds
creating context using euid 0 (save_uid 0)
creating tcp client for server cmsmith-ntap.hq.example.com
creating context with server nfs@cmsmith-ntap.hq.example.com
rpcsec_gss: in authgss_create_default()
rpcsec_gss: in authgss_create()
rpcsec_gss: in authgss_refresh()
rpcsec_gss: in authgss_marshal()
rpcsec_gss: xdr_rpc_gss_cred: encode success (v 1, proc 1, seq 0, svc 1, ctx (nil):0)
rpcsec_gss: xdr_rpc_gss_init_args: encode success (token 0x9e7dbd8:531)
rpcsec_gss: in authgss_refresh()
rpcsec_gss: gss_init_sec_context: A token was invalid - No error
rpcsec_gss: in authgss_destroy()
rpcsec_gss: in authgss_destroy_context()
WARNING: Failed to create krb5 context for user with uid 0 for server cmsmith-ntap.hq.example.com
WARNING: Failed to create krb5 context for user with uid 0 with credentials cache FILE:/tmp/krb5cc_machine_HQ.EXAMPLE.COM for server cmsmith-ntap.hq.example.com
WARNING: Failed to create krb5 context for user with uid 0 with any credentials cache for server cmsmith-ntap.hq.example.com
doing error downcall


------=_Part_31452_2394308.1144954023327
Content-Type: application/octet-stream; name=tcpdump
Content-Transfer-Encoding: 7bit
X-Attachment-Id: f_157yaip
Content-Disposition: attachment; filename="tcpdump"

[root@katana ~]# tcpdump -s 256 host cmsmith-ntap
tcpdump: verbose output suppressed, use -v or -vv for full protocol decode
listening on eth0, link-type EN10MB (Ethernet), capture size 256 bytes
14:09:33.266313 IP katana.hq.example.com.32781 > cmsmith-ntap.hq.example.com.sunrpc: S 3806035236:3806035236(0) win 5840 <mss 1460,sackOK,timestamp 1839472 0,nop,wscale 2>
14:09:33.266397 IP cmsmith-ntap.hq.example.com.sunrpc > katana.hq.example.com.32781: S 1206214847:1206214847(0) ack 3806035237 win 8760 <mss 1460,nop,nop,sackOK,nop,wscale 0,nop,nop,timestamp 212718 1839472>
14:09:33.266421 IP katana.hq.example.com.32781 > cmsmith-ntap.hq.example.com.sunrpc: . ack 1 win 1460 <nop,nop,timestamp 1839472 212718>
14:09:33.266460 IP katana.hq.example.com.32781 > cmsmith-ntap.hq.example.com.sunrpc: P 1:61(60) ack 1 win 1460 <nop,nop,timestamp 1839472 212718>
14:09:33.266662 IP cmsmith-ntap.hq.example.com.sunrpc > katana.hq.example.com.32781: P 1:33(32) ack 61 win 8760 <nop,nop,timestamp 212718 1839472>
14:09:33.266672 IP katana.hq.example.com.32781 > cmsmith-ntap.hq.example.com.sunrpc: . ack 33 win 1460 <nop,nop,timestamp 1839473 212718>
14:09:33.266697 IP katana.hq.example.com.32781 > cmsmith-ntap.hq.example.com.sunrpc: F 61:61(0) ack 33 win 1460 <nop,nop,timestamp 1839473 212718>
14:09:33.266738 IP katana.hq.example.com.krb5_prop > cmsmith-ntap.hq.example.com.nfs: S 3819249688:3819249688(0) win 5840 <mss 1460,sackOK,timestamp 1839473 0,nop,wscale 2>
14:09:33.266835 IP cmsmith-ntap.hq.example.com.sunrpc > katana.hq.example.com.32781: . ack 62 win 8760 <nop,nop,timestamp 212718 1839473>
14:09:33.266891 IP cmsmith-ntap.hq.example.com.sunrpc > katana.hq.example.com.32781: F 33:33(0) ack 62 win 8760 <nop,nop,timestamp 212718 1839473>
14:09:33.266901 IP katana.hq.example.com.32781 > cmsmith-ntap.hq.example.com.sunrpc: . ack 34 win 1460 <nop,nop,timestamp 1839473 212718>
14:09:33.266920 IP cmsmith-ntap.hq.example.com.nfs > katana.hq.example.com.krb5_prop: S 2629679650:2629679650(0) ack 3819249689 win 26280 <mss 1460,nop,nop,sackOK,nop,wscale 0,nop,nop,timestamp 212718 1839473>
14:09:33.266927 IP katana.hq.example.com.krb5_prop > cmsmith-ntap.hq.example.com.nfs: . ack 1 win 1460 <nop,nop,timestamp 1839473 212718>
14:09:33.267710 IP katana.hq.example.com.895209697 > cmsmith-ntap.hq.example.com.nfs: 600 null
14:09:33.268436 IP cmsmith-ntap.hq.example.com.nfs > katana.hq.example.com.895209697: reply ERR 24 null
14:09:33.268454 IP katana.hq.example.com.krb5_prop > cmsmith-ntap.hq.example.com.nfs: . ack 25 win 1460 <nop,nop,timestamp 1839474 212718>
14:09:33.268698 IP katana.hq.example.com.krb5_prop > cmsmith-ntap.hq.example.com.nfs: F 601:601(0) ack 25 win 1460 <nop,nop,timestamp 1839475 212718>
14:09:33.268838 IP cmsmith-ntap.hq.example.com.nfs > katana.hq.example.com.krb5_prop: . ack 602 win 26280 <nop,nop,timestamp 212718 1839475>
14:09:33.268853 IP cmsmith-ntap.hq.example.com.nfs > katana.hq.example.com.krb5_prop: F 25:25(0) ack 602 win 26280 <nop,nop,timestamp 212718 1839475>
14:09:33.268864 IP katana.hq.example.com.krb5_prop > cmsmith-ntap.hq.example.com.nfs: . ack 26 win 1460 <nop,nop,timestamp 1839475 212718>
14:09:33.269367 IP katana.hq.example.com.32782 > cmsmith-ntap.hq.example.com.sunrpc: S 3812066163:3812066163(0) win 5840 <mss 1460,sackOK,timestamp 1839475 0,nop,wscale 2>
14:09:33.269535 IP cmsmith-ntap.hq.example.com.sunrpc > katana.hq.example.com.32782: S 519186120:519186120(0) ack 3812066164 win 8760 <mss 1460,nop,nop,sackOK,nop,wscale 0,nop,nop,timestamp 212718 1839475>
14:09:33.269552 IP katana.hq.example.com.32782 > cmsmith-ntap.hq.example.com.sunrpc: . ack 1 win 1460 <nop,nop,timestamp 1839475 212718>
14:09:33.269605 IP katana.hq.example.com.32782 > cmsmith-ntap.hq.example.com.sunrpc: P 1:61(60) ack 1 win 1460 <nop,nop,timestamp 1839476 212718>
14:09:33.269776 IP cmsmith-ntap.hq.example.com.sunrpc > katana.hq.example.com.32782: P 1:33(32) ack 61 win 8760 <nop,nop,timestamp 212718 1839476>
14:09:33.269784 IP katana.hq.example.com.32782 > cmsmith-ntap.hq.example.com.sunrpc: . ack 33 win 1460 <nop,nop,timestamp 1839476 212718>
14:09:33.269806 IP katana.hq.example.com.32782 > cmsmith-ntap.hq.example.com.sunrpc: F 61:61(0) ack 33 win 1460 <nop,nop,timestamp 1839476 212718>
14:09:33.269834 IP katana.hq.example.com.755 > cmsmith-ntap.hq.example.com.nfs: S 3809533171:3809533171(0) win 5840 <mss 1460,sackOK,timestamp 1839476 0,nop,wscale 2>
14:09:33.269944 IP cmsmith-ntap.hq.example.com.sunrpc > katana.hq.example.com.32782: . ack 62 win 8760 <nop,nop,timestamp 212718 1839476>
14:09:33.269980 IP cmsmith-ntap.hq.example.com.sunrpc > katana.hq.example.com.32782: F 33:33(0) ack 62 win 8760 <nop,nop,timestamp 212718 1839476>
14:09:33.269988 IP katana.hq.example.com.32782 > cmsmith-ntap.hq.example.com.sunrpc: . ack 34 win 1460 <nop,nop,timestamp 1839476 212718>
14:09:33.270006 IP cmsmith-ntap.hq.example.com.nfs > katana.hq.example.com.755: S 1380297960:1380297960(0) ack 3809533172 win 26280 <mss 1460,nop,nop,sackOK,nop,wscale 0,nop,nop,timestamp 212718 1839476>
14:09:33.270013 IP katana.hq.example.com.755 > cmsmith-ntap.hq.example.com.nfs: . ack 1 win 1460 <nop,nop,timestamp 1839476 212718>
14:09:33.270768 IP katana.hq.example.com.567108021 > cmsmith-ntap.hq.example.com.nfs: 600 null
14:09:33.271355 IP cmsmith-ntap.hq.example.com.nfs > katana.hq.example.com.567108021: reply ERR 24 null
14:09:33.271372 IP katana.hq.example.com.755 > cmsmith-ntap.hq.example.com.nfs: . ack 25 win 1460 <nop,nop,timestamp 1839477 212718>
14:09:33.271614 IP katana.hq.example.com.755 > cmsmith-ntap.hq.example.com.nfs: F 601:601(0) ack 25 win 1460 <nop,nop,timestamp 1839478 212718>
14:09:33.271756 IP cmsmith-ntap.hq.example.com.nfs > katana.hq.example.com.755: . ack 602 win 26280 <nop,nop,timestamp 212718 1839478>
14:09:33.271771 IP cmsmith-ntap.hq.example.com.nfs > katana.hq.example.com.755: F 25:25(0) ack 602 win 26280 <nop,nop,timestamp 212718 1839478>
14:09:33.271783 IP katana.hq.example.com.755 > cmsmith-ntap.hq.example.com.nfs: . ack 26 win 1460 <nop,nop,timestamp 1839478 212718>
14:09:33.272278 IP katana.hq.example.com.32783 > cmsmith-ntap.hq.example.com.sunrpc: S 3810741292:3810741292(0) win 5840 <mss 1460,sackOK,timestamp 1839478 0,nop,wscale 2>
14:09:33.272443 IP cmsmith-ntap.hq.example.com.sunrpc > katana.hq.example.com.32783: S 3613502235:3613502235(0) ack 3810741293 win 8760 <mss 1460,nop,nop,sackOK,nop,wscale 0,nop,nop,timestamp 212719 1839478>
14:09:33.272458 IP katana.hq.example.com.32783 > cmsmith-ntap.hq.example.com.sunrpc: . ack 1 win 1460 <nop,nop,timestamp 1839478 212719>
14:09:33.272492 IP katana.hq.example.com.32783 > cmsmith-ntap.hq.example.com.sunrpc: P 1:61(60) ack 1 win 1460 <nop,nop,timestamp 1839478 212719>
14:09:33.272663 IP cmsmith-ntap.hq.example.com.sunrpc > katana.hq.example.com.32783: P 1:33(32) ack 61 win 8760 <nop,nop,timestamp 212719 1839478>
14:09:33.272671 IP katana.hq.example.com.32783 > cmsmith-ntap.hq.example.com.sunrpc: . ack 33 win 1460 <nop,nop,timestamp 1839479 212719>
14:09:33.272693 IP katana.hq.example.com.32783 > cmsmith-ntap.hq.example.com.sunrpc: F 61:61(0) ack 33 win 1460 <nop,nop,timestamp 1839479 212719>
14:09:33.272722 IP katana.hq.example.com.756 > cmsmith-ntap.hq.example.com.nfs: S 3805678510:3805678510(0) win 5840 <mss 1460,sackOK,timestamp 1839479 0,nop,wscale 2>
14:09:33.272831 IP cmsmith-ntap.hq.example.com.sunrpc > katana.hq.example.com.32783: . ack 62 win 8760 <nop,nop,timestamp 212719 1839479>
14:09:33.272864 IP cmsmith-ntap.hq.example.com.sunrpc > katana.hq.example.com.32783: F 33:33(0) ack 62 win 8760 <nop,nop,timestamp 212719 1839479>
14:09:33.272872 IP katana.hq.example.com.32783 > cmsmith-ntap.hq.example.com.sunrpc: . ack 34 win 1460 <nop,nop,timestamp 1839479 212719>
14:09:33.272891 IP cmsmith-ntap.hq.example.com.nfs > katana.hq.example.com.756: S 3167165856:3167165856(0) ack 3805678511 win 26280 <mss 1460,nop,nop,sackOK,nop,wscale 0,nop,nop,timestamp 212719 1839479>
14:09:33.272897 IP katana.hq.example.com.756 > cmsmith-ntap.hq.example.com.nfs: . ack 1 win 1460 <nop,nop,timestamp 1839479 212719>
14:09:33.273740 IP katana.hq.example.com.2004919699 > cmsmith-ntap.hq.example.com.nfs: 600 null
14:09:33.274325 IP cmsmith-ntap.hq.example.com.nfs > katana.hq.example.com.2004919699: reply ERR 24 null
14:09:33.274342 IP katana.hq.example.com.756 > cmsmith-ntap.hq.example.com.nfs: . ack 25 win 1460 <nop,nop,timestamp 1839480 212719>
14:09:33.274603 IP katana.hq.example.com.756 > cmsmith-ntap.hq.example.com.nfs: F 601:601(0) ack 25 win 1460 <nop,nop,timestamp 1839481 212719>
14:09:33.274742 IP cmsmith-ntap.hq.example.com.nfs > katana.hq.example.com.756: . ack 602 win 26280 <nop,nop,timestamp 212719 1839481>
14:09:33.274757 IP cmsmith-ntap.hq.example.com.nfs > katana.hq.example.com.756: F 25:25(0) ack 602 win 26280 <nop,nop,timestamp 212719 1839481>
14:09:33.274768 IP katana.hq.example.com.756 > cmsmith-ntap.hq.example.com.nfs: . ack 26 win 1460 <nop,nop,timestamp 1839481 212719>


------=_Part_31452_2394308.1144954023327--


-------------------------------------------------------
This SF.Net email is sponsored by xPML, a groundbreaking scripting language
that extends applications into web and mobile media. Attend the live webcast
and join the prime developer group breaking into this new coding territory!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=110944&bid=241720&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
