From: Holger Smolinski <smolinski@de.ibm.com>
Subject: NFS re-export of non-local mountpoint
Date: Mon, 2 Jan 2006 15:51:20 +0100
Message-ID: <OF9EFE8519.B9EB421D-ONC12570EA.004FBF22-C12570EA.00519D78@de.ibm.com>
Mime-Version: 1.0
Content-Type: multipart/signed;
	 protocol="application/x-pkcs7-signature";
	 micalg=sha1;
	 boundary=-------z3826_boundary_sign
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EtR26-0002OE-TX
	for nfs@lists.sourceforge.net; Mon, 02 Jan 2006 06:51:34 -0800
Received: from mtagate2.de.ibm.com ([195.212.29.151])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1EtR25-0000k4-7G
	for nfs@lists.sourceforge.net; Mon, 02 Jan 2006 06:51:35 -0800
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate2.de.ibm.com (8.12.10/8.12.10) with ESMTP id k02EpMhu138696
	for <nfs@lists.sourceforge.net>; Mon, 2 Jan 2006 14:51:22 GMT
Received: from d12av04.megacenter.de.ibm.com (d12av04.megacenter.de.ibm.com [9.149.165.229])
	by d12nrmr1607.megacenter.de.ibm.com (8.12.10/NCO/VERS6.8) with ESMTP id k02EpMq8223862
	for <nfs@lists.sourceforge.net>; Mon, 2 Jan 2006 15:51:22 +0100
Received: from d12av04.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av04.megacenter.de.ibm.com (8.12.11/8.13.3) with ESMTP id k02EpMVF018813
	for <nfs@lists.sourceforge.net>; Mon, 2 Jan 2006 15:51:22 +0100
Received: from d12ml064.megacenter.de.ibm.com (d12ml064.megacenter.de.ibm.com [9.149.167.10])
	by d12av04.megacenter.de.ibm.com (8.12.11/8.12.11) with ESMTP id k02EpMAJ018809
	for <nfs@lists.sourceforge.net>; Mon, 2 Jan 2006 15:51:22 +0100
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

This is an S/MIME signed message.

---------z3826_boundary_sign
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: quoted-printable

Happy New Year,

We are looking for a solution, that will allow us to re-export a non-local =

mountpoint (e.g. Samba Share, or NFSmount) through at least NFSv3 to=20
another system using a Linux NFS Server.
Sinde knfsd lacks this functionality and we are not aware of any currently =

maintained user space  Linux NFS Server, that has this capability, we are=20
currently assessing the effort to add this functions to the knfsd. So far=20
I have understood, that the problem is in the file structure, that has to=20
carry 2 server file handles for the file and its parent directory, while=20
the current file structure has only space for inode numbers, that are=20
shorter than NFS server file handles. Are there any other issues, you see=20
and we need to take care of?

As a solution to the file structure space issue, one could imagine kind of =

a translation table, which correlates index numbers stored in the inode=20
fields of the file structure and NFS server file handles like fully=20
qualified path & file name for an NFSmount. Then the knfsd could handle=20
these files like local files and reexport them like others. Would such a=20
solution be acceptable for the common code base, or would it be a special=20
hack forever? What would we need to specially take care of, when=20
implementing this idea?

Best Regards
        Holger Smolinski
--=20
Dr. Holger Smolinski, Linux Technology Center, Linux on zSeries
Author of the '-t2'-Option
IBM Deutschland Entwicklung GmbH,Sch=F6naicher Str. 220, 71032 B=F6blingen
FAX: +49-7031-16-3456, Tel. +49-7031-16-4652

---------z3826_boundary_sign
Content-Type: application/x-pkcs7-signature; name="smime.p7s"
Content-Transfer-Encoding: base64
Content-Disposition: attachment; filename="smime.p7s"
Content-Description: S/MIME Cryptographic Signature

MIAGCSqGSIb3DQEHAqCAMIIURAIBATELMAkGBSsOAwIaBQAwCwYJKoZIhvcNAQcBoIISZDCCAtow
ggJDoAMCAQICAwMUtjANBgkqhkiG9w0BAQQFADBOMQswCQYDVQQGEwJVUzEQMA4GA1UEChMHRXF1
aWZheDEtMCsGA1UECxMkRXF1aWZheCBTZWN1cmUgQ2VydGlmaWNhdGUgQXV0aG9yaXR5MB4XDTAy
MDExNDIyMDcxMVoXDTExMTIzMTIyMDcxMVowaTELMAkGA1UEBhMCVVMxNDAyBgNVBAoTK0ludGVy
bmF0aW9uYWwgQnVzaW5lc3MgTWFjaGluZXMgQ29ycG9yYXRpb24xJDAiBgNVBAMTG0lCTSBDZXJ0
aWZpY2F0aW9uIEF1dGhvcml0eTCBnzANBgkqhkiG9w0BAQEFAAOBjQAwgYkCgYEA629xc49NpAPz
cAsuShTImLRYMkyepDEkC1UrPbsFRyAFZKsv3pw0MGfW/+7glzJKgPkPzlTZZfznznGbmAWVnNBQ
lyPasOtCjif603euRXReHcKfHMPLItKozibWIPHJuOnwNclOnnP2sKufuPzbTImQTTi5c8JZNZcM
J0YFzTcCAwEAAaOBqjCBpzARBglghkgBhvhCAQEEBAMCAIcwDgYDVR0PAQH/BAQDAgHGMB0GA1Ud
DgQWBBSuVA6S6qgzqSskLcfIbzDc3vNKQDAfBgNVHSMEGDAWgBRI5mj5K9KylddH2CMgEE8zmJCf
1DAPBgNVHRMBAf8EBTADAQH/MDEGA1UdJQQqMCgGCCsGAQUFBwMBBggrBgEFBQcDAgYIKwYBBQUH
AwMGCCsGAQUFBwMEMA0GCSqGSIb3DQEBBAUAA4GBADJye3NmC8q2PzypRZfu7JvDRDX1rRcanZvu
jQupk2oCScMd3FIHLE7hOfu8YffvxtLU3y8wNamQEORjTD175qAffryXypwtiVjBUKSDlBCQ14ke
McF9ViNdewEoBGiAycUq8R3Lrlf4TCDvW4GeguNTFFZnS0ygYATiJk7iDyvEMIIC2jCCAkOgAwIB
AgIDAxS2MA0GCSqGSIb3DQEBBAUAME4xCzAJBgNVBAYTAlVTMRAwDgYDVQQKEwdFcXVpZmF4MS0w
KwYDVQQLEyRFcXVpZmF4IFNlY3VyZSBDZXJ0aWZpY2F0ZSBBdXRob3JpdHkwHhcNMDIwMTE0MjIw
NzExWhcNMTExMjMxMjIwNzExWjBpMQswCQYDVQQGEwJVUzE0MDIGA1UEChMrSW50ZXJuYXRpb25h
bCBCdXNpbmVzcyBNYWNoaW5lcyBDb3Jwb3JhdGlvbjEkMCIGA1UEAxMbSUJNIENlcnRpZmljYXRp
b24gQXV0aG9yaXR5MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDrb3Fzj02kA/NwCy5KFMiY
tFgyTJ6kMSQLVSs9uwVHIAVkqy/enDQwZ9b/7uCXMkqA+Q/OVNll/OfOcZuYBZWc0FCXI9qw60KO
J/rTd65FdF4dwp8cw8si0qjOJtYg8cm46fA1yU6ec/awq5+4/NtMiZBNOLlzwlk1lwwnRgXNNwID
AQABo4GqMIGnMBEGCWCGSAGG+EIBAQQEAwIAhzAOBgNVHQ8BAf8EBAMCAcYwHQYDVR0OBBYEFK5U
DpLqqDOpKyQtx8hvMNze80pAMB8GA1UdIwQYMBaAFEjmaPkr0rKV10fYIyAQTzOYkJ/UMA8GA1Ud
EwEB/wQFMAMBAf8wMQYDVR0lBCowKAYIKwYBBQUHAwEGCCsGAQUFBwMCBggrBgEFBQcDAwYIKwYB
BQUHAwQwDQYJKoZIhvcNAQEEBQADgYEAMnJ7c2YLyrY/PKlFl+7sm8NENfWtFxqdm+6NC6mTagJJ
wx3cUgcsTuE5+7xh9+/G0tTfLzA1qZAQ5GNMPXvmoB9+vJfKnC2JWMFQpIOUEJDXiR4xwX1WI117
ASgEaIDJxSrxHcuuV/hMIO9bgZ6C41MUVmdLTKBgBOImTuIPK8QwggMgMIICiaADAgECAgQ13vTP
MA0GCSqGSIb3DQEBBQUAME4xCzAJBgNVBAYTAlVTMRAwDgYDVQQKEwdFcXVpZmF4MS0wKwYDVQQL
EyRFcXVpZmF4IFNlY3VyZSBDZXJ0aWZpY2F0ZSBBdXRob3JpdHkwHhcNOTgwODIyMTY0MTUxWhcN
MTgwODIyMTY0MTUxWjBOMQswCQYDVQQGEwJVUzEQMA4GA1UEChMHRXF1aWZheDEtMCsGA1UECxMk
RXF1aWZheCBTZWN1cmUgQ2VydGlmaWNhdGUgQXV0aG9yaXR5MIGfMA0GCSqGSIb3DQEBAQUAA4GN
ADCBiQKBgQDBXbFYZwhi7qCaLR8IbZEUaJgKHv7aBG8ThGIhw9F8zp8F4LgB8E407OKKlQRkrPFr
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
GsvyAu+vm2RDetEpOHZAVXlBvgYAAAAA

---------z3826_boundary_sign--


-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://ads.osdn.com/?ad_id=7637&alloc_id=16865&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
