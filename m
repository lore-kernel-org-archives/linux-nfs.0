From: Klaus Steinberger <Klaus.Steinberger@physik.uni-muenchen.de>
Subject: Re: fsid question
Date: Fri, 30 Mar 2007 08:38:29 +0200
Message-ID: <200703300838.32685.Klaus.Steinberger@physik.uni-muenchen.de>
References: <mailman.7028.1175219061.5558.nfs@lists.sourceforge.net>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============0160109544=="
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HXAlA-0003CX-Aq
	for nfs@lists.sourceforge.net; Thu, 29 Mar 2007 23:38:52 -0700
Received: from mail.physik.uni-muenchen.de ([192.54.42.129])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HXAlB-0007Oc-63
	for nfs@lists.sourceforge.net; Thu, 29 Mar 2007 23:38:54 -0700
Received: from localhost (unknown [127.0.0.1])
	by mail.physik.uni-muenchen.de (Postfix) with ESMTP id 280C020065
	for <nfs@lists.sourceforge.net>; Fri, 30 Mar 2007 08:38:47 +0200 (CEST)
Received: from mail.physik.uni-muenchen.de ([127.0.0.1])
	by localhost (mail.physik.uni-muenchen.de [127.0.0.1]) (amavisd-new,
	port 10023)
	with LMTP id 6wgqoKvjaaiJ for <nfs@lists.sourceforge.net>;
	Fri, 30 Mar 2007 08:38:46 +0200 (CEST)
Received: from [172.23.17.209] (tmo-102-13.customers.d1-online.com
	[80.187.102.13])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mail.physik.uni-muenchen.de (Postfix) with ESMTP id 1924A20032
	for <nfs@lists.sourceforge.net>; Fri, 30 Mar 2007 08:38:46 +0200 (CEST)
In-Reply-To: <mailman.7028.1175219061.5558.nfs@lists.sourceforge.net>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

--===============0160109544==
Content-Type: multipart/signed; boundary="nextPart6999505.zr8cbGAelt";
	protocol="application/pkcs7-signature"; micalg=sha1
Content-Transfer-Encoding: 7bit

--nextPart6999505.zr8cbGAelt
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline


> Well, I still don't see anywhere there is a documented definition that
> says "(NFS) fsid _is_ based on major/minor number". The man page
> describes it as "the filesystem identification portion of the file

I could not tell you out of memory where it is defined, too bad it's not in=
=20
the man page: Should be enhanced!

Definitly the default for fsid is based on major/minor number, as long as y=
ou=20
don't have a fsid option in you're exports file.

> On the other hand, arguments like these are kind of silly. The important
> thing is to advocate and make sure people know how to use "fsid" in a
> clustered environment.

Not only in clustered environment. It is necessary to use fsid in an LVM=20
environment. I learned this also the hard way, I always wondered about stal=
e=20
handles on clients after server reboots and reexports, until I learned that=
=20
lvm minor numbers can change, and until I discovered fsid.

But be careful! There is nothing that prevents you from using same fsid for=
=20
different exports.=20

Sincerly,
Klaus



=2D-=20
Klaus Steinberger         Beschleunigerlaboratorium
Phone: (+49 89)289 14287  Am Coulombwall 6, D-85748 Garching, Germany
=46AX:   (+49 89)289 14280  EMail: Klaus.Steinberger@Physik.Uni-Muenchen.DE
URL: http://www.physik.uni-muenchen.de/~Klaus.Steinberger/

--nextPart6999505.zr8cbGAelt
Content-Type: application/pkcs7-signature; name="smime.p7s"
Content-Disposition: attachment; filename="smime.p7s"
Content-Transfer-Encoding: base64

MIAGCSqGSIb3DQEHAqCAMIACAQExCzAJBgUrDgMCGgUAMIAGCSqGSIb3DQEHAQAAoIIFjDCCBYgw
ggRwoAMCAQICIgIcEfzCWRj84N0ovUz5SjKEgQwQzxFCqIulIz0HiQICHeowDQYJKoZIhvcNAQEF
BQAwMTEaMBgGA1UECxMRT3JnYW5pemF0aW9uYWwgQ0ExEzARBgNVBAoUClBIWVNJS19MTVUwHhcN
MDYwNzE4MjExNzUxWhcNMDgwNzE4MjExNzUxWjBRMRowGAYDVQQDExFLbGF1cy5TdGVpbmJlcmdl
cjEPMA0GA1UECxMGQ2FtcHVzMREwDwYDVQQLEwhQZXJzb25lbjEPMA0GA1UEChMGcGh5c2lrMIIB
IjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAoQVr41ywihIxYYm2VkGZfaGY9Tim6Zjr33mt
rJozo2C7nBzp0LRCnCE1r9A6ChqJQAT9Ue8zFSqolTiggpot3/A8yjO4Vhl6g+iDVowYCPsQ+ZQF
jEMOvAzx+QO68T24m6a2gXjvMTNxGthZ2a5vwumjXBl+WcFDKMpUawgq1Fi8SLgZkhpQiRqBuV/c
M+mwDw4VTTrTojMaGnuZ42BfRZgWN4z2HzEpw/jWVgjb3TRI6iPcJCTQkFjJvWFjCVVUhNxY4WcT
PHk0eknF6XP6OmSJYtcuvh8T8k1dQkbw2gGCvkAquno95oU9IUWTdAefJbqPnlFay8QEfgxw+2tN
LQIDAQABo4ICaDCCAmQwHQYDVR0OBBYEFEarvDrx/qplN8kFmZEuWKKYIcHmMB8GA1UdIwQYMBaA
FCd+as72rN8F4f01rGTrSFAPb99YMDMGA1UdEQQsMCqBKEtsYXVzLlN0ZWluYmVyZ2VyQHBoeXNp
ay51bmktbXVlbmNoZW4uZGUwggHMBgtghkgBhvg3AQkEAQSCAbswggG3BAIBAAEB/xMdTm92ZWxs
IFNlY3VyaXR5IEF0dHJpYnV0ZSh0bSkWQ2h0dHA6Ly9kZXZlbG9wZXIubm92ZWxsLmNvbS9yZXBv
c2l0b3J5L2F0dHJpYnV0ZXMvY2VydGF0dHJzX3YxMC5odG0wggFIoBoBAQAwCDAGAgEBAgFGMAgw
BgIBAQIBCgIBaaEaAQEAMAgwBgIBAQIBRjAIMAYCAQECAQoCAWmiBgIBFAEB/6OCAQSgWAIBAgIC
AP8CAQADDQCAAAAAAAAAAAAAAAADCQCAAAAAAAAAADAYMBACAQACCH//////////AQEAAgQG8N9I
MBgwEAIBAAIIf/////////8BAQACBAbw30ihWAIBAgICAP8CAQADDQBAAAAAAAAAAAAAAAADCQBA
AAAAAAAAADAYMBACAQACCH//////////AQEAAgQR/MJZMBgwEAIBAAIIf/////////8BAQACBBH8
wlmiTjBMAgECAgEAAgIA/wMNAIAAAAAAAAAAAAAAAAMJAIAAAAAAAAAAMBIwEAIBAAIIf///////
//8BAQAwEjAQAgEAAgh//////////wEBADAdBgNVHSUEFjAUBggrBgEFBQcDAgYIKwYBBQUHAwQw
DQYJKoZIhvcNAQEFBQADggEBADn6nE8CjYaTPbQvB3St+tJk5MoJRXkAvFZ2JgotA3cB9447W/EY
HNe37KwbttFpKHZ2hhJ0dacWieodQvyrT+jH1z4/TEhSy5QNKkScuiYI2BcTydFuXC2QYjBfDkny
JrzEdlt9HxAAcegVDNGN3nrwNFfY5FhdSq64mZWMK7GJzI9rQ80DbMqK6sua2LpXMoOYiDgONsDa
HWkqVX4P0HmhEqRs/BK+YUDgtI+Do7Uymyz3QlW9WSoyfkYIdTLOS1CkcYwpAh4deDs3ib+5qJsE
x9/KSRbtDdvgFhAihvOpdWfmRhFPF0E2dxiYZAGuYmhQ8Ur053fg6pQ36G/tJj0xggIIMIICBAIB
ATBXMDExGjAYBgNVBAsTEU9yZ2FuaXphdGlvbmFsIENBMRMwEQYDVQQKFApQSFlTSUtfTE1VAiIC
HBH8wlkY/ODdKL1M+UoyhIEMEM8RQqiLpSM9B4kCAh3qMAcGBSsOAwIaoIGLMBgGCSqGSIb3DQEJ
AzELBgkqhkiG9w0BBwEwHAYJKoZIhvcNAQkFMQ8XDTA3MDMzMDA2MzgyOVowIwYJKoZIhvcNAQkE
MRYEFDLNEx4fSFVE3IXf8pNxjx9nd4UPMCwGCSqGSIb3DQEJDzEfMB0wDQYJYIZIAWUDBAECBQAw
DAYIKoZIhvcNAwcFADALBgkqhkiG9w0BAQEEggEAfCd9PjKvcpPjiuBYqDE8k0i/bEdBZe+4CjWN
qVrYr3uImdLdYe228WW8WhNJgn+EK8OVwXvWfyar6XJJeNZgto2CEeOpM7onpxhRl0EYNiapViR1
fIpHL1JoAMtipyYHhICpgaoWvA7ZM99Kk+8Kmy02qCgkHNwmMGaOfzOTtdDKlIhNFiXObta+Racm
GbbzvlmAk3KprsJMNxtFkLFlk3EbsvtOGLqroEk4QuAHOdLqVZ6b1ujz2d8/MKt4EoP9FSGvG4ra
5Wgvt7eQ7S2V2Y+1YY6CQ61rF93aXr13zod67q+N+ftbTzjjSRJmANvPx5NXUmi9iDm8BpnqMs0k
jgAAAAAAAA==

--nextPart6999505.zr8cbGAelt--


--===============0160109544==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
--===============0160109544==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--===============0160109544==--
