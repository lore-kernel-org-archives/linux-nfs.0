From: Steven Shiau <steven@nchc.org.tw>
Subject: Re: NFS service takes very long time to start when internet
 disconnected..
Date: Mon, 26 Jul 2004 14:40:34 +0800
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <4104A762.7050302@nchc.org.tw>
References: <20040724063635.GA25341@lfod.nchc.org.tw> <20040724181902.GB18548@suse.de> <20040725030001.GA11045@lfod.nchc.org.tw> <20040725122345.GB8512@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BozA9-00016P-Ay
	for nfs@lists.sourceforge.net; Sun, 25 Jul 2004 23:40:41 -0700
Received: from mail.nchc.org.tw ([140.110.16.6])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.34)
	id 1BozA8-0004ko-OY
	for nfs@lists.sourceforge.net; Sun, 25 Jul 2004 23:40:41 -0700
To: Olaf Kirch <okir@suse.de>
In-Reply-To: <20040725122345.GB8512@suse.de>
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

Hi, Olaf :
Yes, I did, my /etc/hosts in the NFS server looks like:
------------------------------------------------------
# Do not remove the following line, or various programs
# that require network functionality will fail.
127.0.0.1               localhost.localdomain localhost
...
192.168.101.254 nfsserver_eth1.drbl.sf.net nfsserver_eth1 drblrh.nchc.org=
.tw
192.168.101.1 drblrh-1-001.drbl.sf.net drblrh-1-001
...
------------------------------------------------------
Any idea ?
Thanks.

Olaf Kirch wrote:
> On Sun, Jul 25, 2004 at 11:00:01AM +0800, Steven Shiau wrote:
>=20
>>So is it the problem of initlog when my eth0 disconnects ?
>>If so, why ? How can I solve it ?
>=20
>=20
> Did you try putting these addresses into /etc/hosts along with some
> names? Could be that using addresses is not enough,and exportfs is
> doing a reverse lookup by default.
>=20
> Olaf

--=20
Say YES to Openoffice.org (www.openoffice.org, openoffice.nchc.org.tw).
Please AVOID distributing documents in WORD, EXCEL or POWERPOINT format.
[Chinese Big5] =E8=AB=8B=E9=81=BF=E5=85=8D=E6=95=A3=E4=BD=88WORD, EXCEL =E6=
=88=96=E6=98=AF POWERPOINT=E6=A0=BC=E5=BC=8F=E7=9A=84=E6=AA=94=E6=A1=88.
See http://www.fsf.org/philosophy/no-word-attachments.html
and http://www.cyut.edu.tw/~ckhung/a/c_91.shtml
-------------------------------------------------------------------------=
----
Steven Shiau [Chinese Big5] =E8=95=AD=E5=BF=97=E6=A6=A5
NCHC [Chinese Big5] =E5=9C=8B=E5=AE=B6=E9=AB=98=E9=80=9F=E7=B6=B2=E8=B7=AF=
=E8=88=87=E8=A8=88=E7=AE=97=E4=B8=AD=E5=BF=83
E-mail: steven _at_ nchc.org.tw; steven _at_ stick.idv.tw


-------------------------------------------------------
This SF.Net email is sponsored by BEA Weblogic Workshop
FREE Java Enterprise J2EE developer tools!
Get your free copy of BEA WebLogic Workshop 8.1 today.
http://ads.osdn.com/?ad_id=4721&alloc_id=10040&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
