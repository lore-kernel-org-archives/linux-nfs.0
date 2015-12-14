Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail3.dit.upm.es ([138.4.2.18]:46069 "EHLO mail3.dit.upm.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751356AbbLNQ5W (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 14 Dec 2015 11:57:22 -0500
Subject: Re: possible bug in nfs-kernel-server
To: "J. Bruce Fields" <bfields@fieldses.org>,
        Soumya Koduri <skoduri@redhat.com>
References: <564EFE51.90105@dit.upm.es>
 <20151121091824.71ab1f6b@tlielax.poochiereds.net>
 <b259acd35a93bd2293630c35b8761e6b@dit.upm.es> <566954D6.7090508@dit.upm.es>
 <5669702D.50402@redhat.com> <20151210144434.GB12544@fieldses.org>
Cc: Jeff Layton <jlayton@poochiereds.net>, linux-nfs@vger.kernel.org,
        =?UTF-8?Q?administraci=c3=b3n_del_centro_de_c=c3=a1lculo_del_dit?=
	<cdc@dit.upm.es>
From: Omar Walid Llorente <omar@dit.upm.es>
Message-ID: <566EF4E4.60809@dit.upm.es>
Date: Mon, 14 Dec 2015 17:57:08 +0100
MIME-Version: 1.0
In-Reply-To: <20151210144434.GB12544@fieldses.org>
Content-Type: multipart/mixed;
 boundary="------------090706020302080707010702"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is a multi-part message in MIME format.
--------------090706020302080707010702
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 8bit


Thank you Bruce, others, for the responses. I send attached a complete 
capture of the issue, including the glusterfs transactions.

Hope this helps to clear where may it be...

Omar

El 10/12/15 a las 15:44, J. Bruce Fields escribió:
> On Thu, Dec 10, 2015 at 05:59:33PM +0530, Soumya Koduri wrote:
>>
>> On 12/10/2015 04:02 PM, Omar Walid Llorente wrote:
>>> Hi, Jeff, Bruce, finally I got some time to get the capture of the nfs
>>> packets (you can find them in attached file nfs-problem-nks.pcap.zip).
>>> Sorry for being so late.
>>>
>>> What I did was the following:
>>>
>>> 1st) Create the RO file:
>>> cdc@l056:~/prueba-git$ rm -f kk.txt 444.txt; echo "prueba" > 444.txt;
>>> chmod 444 444.txt;
>>>
>>> 2nd) Init the capture:
>>> root@l056:~# tcpdump -i eth2 -w /tmp/nfs.pcap -s 512 port 2049
>>> tcpdump: listening on eth2, link-type EN10MB (Ethernet), capture size
>>> 512 bytes
>>>
>> GlusterFS protocol is added to wireshark from version 1.8.0 [1]. It
>> may be helpful to see what GlusterFS operations are being processed
>> as part of NFS WRITE call (which has failed in this case).
>>
>> Could you please try taking the packet trace on the machine where
>> NFS server is running (without filtering out based on the port
>> number).
>>
>> Also I tried out the same test on Fedora22 machine, but haven't run
>> into any issue. What are the fuse mount options you have used to
>> mount gluster volume?
> Oh, I think this is a simple problem (but maybe hard to fix).  The
> capture shows NFSv3 traffic like:
>
> 	CREATE -> OK
> 	SETATTR (mode set to 0400) -> OK
> 	WRITE -> NFS3ERR_ACCES
>
> That write would succeed locally (because the mode doesn't matter to a
> local application that already holds the file open).  It would fail over
> NFSv3, which doesn't know about the open--except that there's a hack for
> this case: NFSv3 servers allow IO operations to ignore the mode, if the
> operation comes from the owner of the file.  NFSv3 clients are then
> careful to perform necessary access checks on open to ensure that this
> owner-override rule doesn't grant too many permissions.
>
> That allows NFSv3 applications to see behavior that's mostly like a
> local filesystem, without opening much of a security hole (since the
> owner could always chmod anyway).
>
> So, knfsd is making this special exception--but gluster (which I believe
> it's exporting in this case, via fuse?)--probably doesn't....  I'm not
> sure what you can do about that.
>
> --b.

-- 
----------------------------------------------------------------
Centro de Cálculo         Depto. Ingeniería Sistemas Telemáticos
E-mail: omar@dit.upm.es        Universidad Politécnica de Madrid
Fax:(+34) 913367333                 E.T.S. Ing. Telecomunicación
Tel:(+34) 915495700-Ext.3005                28040 Madrid (Spain)
Tel:(+34) 915495762-Ext.3005
Tel:(+34) 913367366-Ext.3005
----------------------------------------------------------------


--------------090706020302080707010702
Content-Type: application/zip;
 name="nfs-problem-nks+glusterfs.pcap.zip"
Content-Transfer-Encoding: base64
Content-Disposition: attachment;
 filename="nfs-problem-nks+glusterfs.pcap.zip"

UEsDBBQAAAAIANWNjkd64g7npBEAAMZNAAAeABwAbmZzLXByb2JsZW0tbmtzK2dsdXN0ZXJm
cy5wY2FwVVQJAANx8m5WcfJuVnV4CwABBOgDAAAE6AMAAO1cC1QUR9auGWaA4IAkKgzoSQTH
R1yGAA6ID6Ih4FtAJMb88awKw0sFEwTfG9ElOLKA6K+iMepJQjaaXR/Jsr8kikzEJGZNNlkh
uqhZo2heugIqjzw2s3VrunuqupsWVozs+elzmmpmhtv33u+7t27drqG2+u1X1EiDhEONkAoP
p5syZx34yh1F4ms4Ub/3W15YhOJmFaEIVxSNkMnrofFovHMvnwKNeic+W2zfW938J3pfeyni
Rlyup7bMx4olqVzdtD7HDL79Z0aAxGOUxJLL727fZaElVpwDiWkbOImVtlarNnqe/8KGuZcr
iMT1DokLp9S3gsQPRDqWbqcl2qJAot8VTmKbrcWqLbRMmx6bUbg+11M/zuc4JXFqTDFIfOFr
SiKRZbfdLrFxOUgMehssBqlWN9v3YDG2/DrW8Y9lD9kl+vZP+VDr8+ZrILFQItFuu11iyGiQ
2PAoWEwkam2tYDG2fBFInBpll7hwSus6XuImWR1Lt9slJvwaJH78F7CYk9gCFmPLY0BiciEn
cWqiDy/xosHDITE2JqloDe3HDaEgcftozo9v2dqs2pVHsooqLU+uzvXst9ZnleDHYQunjvkA
JO4Z7CHWkci1S9xBrLaEgjROxzaQhqUWg47j+vA6xsZjHV8HiX2ek0ikkVlBkHlLhEysgIyb
gMxnvNV+tEQpw/sQhutFDL8uw/AAwBskNucoWj2GWG0SWb1KsNpDsHo2b7VmqSIyYQSZUSJk
imWQMYIvQWL2OrGODB+Jjg3DRHw8LPBxjMDHQt6P6yiJMnF9nsS1RRTXi2Ti2ggsB4klm+Ww
Fhg+lzD8IxHD8wWGrxMYbuB13LPZQylTRJNMUS/KFDEymeIxiJsaLPH9tTp0Awu7wesY7jlv
6q9zPiESv6z+HUgcjGPmkfACzcMPqT90VVmH93ugrvnh8Fy95nT8YLtEpH22Duu4MxehvY2P
pTkLeViV/xoeITWruHMSQtrV8NqioNAwhMbg66E43yAdHj3t16N34vNlfO7C526EHn8RnwX4
3IbPV/H5Bj7/gKQHzvvIC599VUi11glfLF+D0MDWt+Zy7z9APuOp8kVBr44G6398UYfcsFZw
2u22+4BY/1PrKLC+aTFYDh5wVak/BMuxB/6cq3f6ufcI3p9VxAPY+hOc9SoZ7cRa8hohWit8
jcUg7az0K3sH7Pm/Fdz73tzoxAvZlHzyfNzLe6vwrWzc/bTBoSEh4fa3tcFBQUEhsrdG6KnG
p3c8XGKtgGv6Pk+FeT0PI3hmaL6O5S7NC1N1IeHFVREv/lzX/AjK9dR8M2MFzYsqN5BYUqRD
aqwnnBKJt6uLiESDrES95pv4UaxE7KSjTfePaRokw7S9NoFpvfHpvHBhYPbybPK7G5JhX3Kp
Dq3EL8IpYd+iVjK7NP3Msu8RZB3ulYM94jI9QGBfL459pqb22aemRp59oKUaNKktVcwCxQSb
kSw2XjlYm3CCjSMLnANtsCZ7b3azLDCtuf0sYNypmAXIXNKUIcIBZwFvP2x976n5DA7nsPUn
bnZNFlDNymw6Fnp5/xrufRduFLLAWud9r1wxra/DHzWgTmYBIjttp4twzd2HXL9eFg2eKcOe
acGvtcjx4pvqjYQXgSwvvP3qmgdCzNrijRJeHLp1/3jhdAdewEtGgR8I6VGQPRe+s0uH8NRJ
Tgk/ylvHEn6Us/wYiOPU+3PsBe+/zpTwY/WtO/OD15bG28j9jYMvnJb4GCbHlfZwNe7G2R1L
ipTJxSpTdQlYZLgkwvVzbFVurl7bL36FBNefbt8/XLVyuFK5GO7jwXt797eZszi36xc/l5w5
MN0M0Tbc/pJq+am1fbWUbBeTycQncTcJR6gcMuA1HdqNBe+WySGqktYI8GjjWRFHcq3D9cCR
gUV/Eziis3NENfv2nTnCW85bSUzgLVzK/c7HORXvGuSYDxCPEv93y9q/nxs3KkUQQnI87WZ5
7ROM1gQsdYIc/8OrNxH+X2D5r8f897uA+R8Q/xuB/+cBMYwWau6+tQjcpzfvng7yHz6iPv+s
Fl0bKNznjvXMjwdwDMA94BPilWiJV1/wqtsR2ZWoXlvmO8BRTcNKFBNlNvbaUcGrfT7Dmqmm
EO20t0rxiP9iuJ7yJhyuYvcsPzX/9saKJ59wVMz2rJ5/SIf+iq/hlKzErY0ryUrcIO2R6Cdh
bf/4+qP8Sjx1P1ePWjht241YsSa0RvgYgtArXC3PWMQf3lTQqvganq/Z6ToerNtzSKfUFehH
ugJeLBb6SdjCC2xXoIpYCBKL3qXQFa/hSzaMBImlF2TX8Hq8hj/rkAhreA7dLXeLbl3v44lL
90WZXqw48Haob0Qtb/8RSlvJar6k4gJZzf9KdjWPuehTT2mLV/Octon3StvT7ypGjheJnHdk
0ZJETup+TtvKe6XtTZG2TBeixDaBdCHyZbsQev0434dpJiT6cNo23ittI48qxvkqEueDRHF+
Afu3DOI8fbkQ5weoOK9ECnEu1oTWCJE4f+KfiMx2snHuRMf5rMltgwYZi/vhMcH0SMoXOM7/
3q/V61+8dXOk1jl6ddYdpDZd/4ZMh/I7sO7R2XyPKS6Usm7LXVjndwfrNBLrnik4KlOjEOuS
j+qU+obhpG84UpRzvqu0RLmyfcMqYiFIXCzxF9U3tIYQf93YKdPHPgn+ytnE9w3b0ih/Jd6F
v/w7ywbD6p/8CBuidl4nbHivt4b31yrKXzI9zC9I1ssXZb2TDXPro9geZhWxECTmyUYP18O0
JswjPcyxMl36N8FfvoeFHqaN8lfjL+mvQY8/MRh4ZWr6n3J+5P1VcFSn1E+dSDLZJVEmezM2
o6gP208lmcwGEr2O6VAWtg1OsUSV2TYJJA48JCsRcuNNx1oRJOLKMgD7q4mzh86N/TuTG+/k
Y+5lusJ7C9nXF9B5VKcuylmSnZyVsiQQakZjitmYtDgnMxuZkF0DpMnOgk+YAx2fNKdlBy5K
z1yYvRiFQM2L3QHwyH4QBZMPPAg6ON5IWpyZnYzvEhYaOiKMt8szNSXdbMxKfh4ZUhumvPNR
7Kcbo1YPT5vmUc1hOrlKsav2OFmt/8CuxPwuWIf71OGV2LDIAwIC7lDfY8aamttfibkLyLAr
MXfQZAPWJAT/VQi/yqBiR2VImA+anDrLxk5Rn0LL9HMQO/pAPnaSELfKvs5xQaKJDR+IXdPd
s+OXjM9LVVQ0ifK/yryB9OdLnWXzP645ff9AR1NcKBdNW7m790RTB6JJZXUgIJ5RVOaKfwAC
qU/JzihQmR6mEMAzCodAUg8CHUegv5WdUei1gcrs5Q0IPHBFtDYoeymiIY0g0OhAAGpYDoFj
PQh0HIERVsU5fTKZ0w+yc/r0c7EZxU7SOT0JcQjc7EGg4wjsek9xJk0kM+kZdiYtdiq0xLrB
TOrlLjuTAgL/b2bS32MPOmNrneWevrZVbyZPcvqzHU+furpm/76k4xkhdDy/gMooF9f+Ld33
SQ7o4YmkvXDJk52DUl4Jq2eVYQfp2q+PZFfPUa4rj2T7Aq+GfCqsnsMoXm1F3ZtXXbpCr5CN
THt3RWVoXA0efOwY211pSPOf6FMLHkxpZLorvAdhdurOHuzSDk6VxIOOjoTKEEI4eCOM7UjU
R0XPG9QGHlziKnQk0ikPQoXVnT3YpV2PquM69Bd8DadkxXe0dRxZ8e1jV3z+fa3DfXfhFV9w
ZIgwP3tAfstFKK+lc89n+a2napl8Q15H/+Fz2ldOKPbcyQ6R0jp2/ZPti3NUm6jnDuufsFx7
p3WboNV/2Gl9L+nYjKefmfa84ymdHYfb7yv2IsnKe/3romzahjVeCkxWvybJphZO23ZxEGtC
a4RIplvLPT+UZZkLwzI6w2H/05iAdXNP6RCelMgpwWLLBrJLpLRWhMXSSkt0HsHivASLOdi6
Uhkset0tFrzGFz/GdSu+zpLDw7yDxIUFsXhE52GtzwAee1ZJ8AjgNFaKC8S/TyLzM8XKeQqp
nA+wlXOsG67dbokqZx1VOd+S8VlP5TxtcXOvUZsm/3zY9r7l4+0n/8khEHhasXJOIpXz56LK
+VahJW40cKDPd0LlrLI/6Sazyy05Dvw3zy5KlXPeacUeFHliUOokivszOJLKRT0onT3uCYe3
c3fv4XAHOHzmtGIP6iLpQSWwPahBbQ1zr5hEPSgdVEkcAuYeBDqOgKlGsQelJz2oerYH5VP7
UkTjbFEPSkf1oPh9Dz0IdACBghrFmXQqmUn3szNp3OjYjI31MjOpikPgdg8CHUfgWI1ir2A8
qW7Hiaqp8pVHljrDTDooRKimRlIzKcwD3Xkm7dJewdBaxZUuWR/cCGVXuldM0fMGDwMPPndV
WOkuoDwIebw7e7BLV7qjJR5kui2/Id2WSrbb0jjbf2J/DXjQ/InQbTlIeRDycHf2YJd2W96U
9aBQD5tJPVzL1sMb6wstMxaABx/8SLYehjzanT3YpfVw6eeO3fCSdXD5BtKvKn2brYeXOlda
JpSRdfCPTD08MhchrJF2B3d3eibyuIuZCNDw40b4G3V6aubirGSjOTk5w7gke352yhIUzFtU
TVkk2TVTXvEl2TXjxNaXg4c1zL1qINWNC1NfLuAsSr6fFp2jMRLvJyz38iH7CTez9Vp/zUsR
TZOIReOZeu0gZ5H1flr0g8giZqdOuW0a2akzh61/ZiyIzSipIfVPpLj+IRY130+LBpzRocv4
+rKcRbW26cSiMSKLvhMsSpRY9DK2qEXGIqe73UVpP3L5C7qaG8xZy1ZQpqMT1lwMnT72tzVp
Jz6qyZzHWTz2rE7p+7DJZC9ZNZt7S2oKLfEF8H3Y6D+xuRckxp+lWCHucJXveILUZAfYmmxC
Gc5H+ZDNr+ZIajI+Fyl3uNTsqFVvKIFR0xyzlRo1zWsuHud+rRZG9VMzwgPUHPOE/1lg41kx
R2qRw0flCSnER5GyPsIW/cpFMj/xPO+URZrDA9aRcd/Bp6lRs+/LrK+4X58Uxm3znIb8fe7k
9ixKlLWI239b3vgC2X8bwNYsTZNwPsoDi/JeldQsfC7qHEZOLt/asbngQY2aFveEx7hfhwjj
pJ0FH/rdKm7PomyJRdQe0vIQ0le9UcbWsVcNeM7YCxYlpUvqWH6+6BxGbXMCyXjt3ZPUqLl2
7V/HuV9dhfFqUOPtlG9T27No/5c6dBrf/bRcVXQiIZVURcEs6zbN5Fn3TL7AOjX3fZhCJHyn
BKmdDB9HctbR363iD4N5VFBKUkhYiHFk2PxRRpNphMkYHpoYbpyfnBgyIjR4/giz2cT9PTzV
HStOL1SagcOfy1Xtdf2ZmgxXNzXB54+/QY8h+lN1d1lRSddF9oqKuZeML+7JAQgfxwhvwx7Z
JoewJSGNILyIRXhzPY+wapAE4ThutmmXs/8FKHWo7v2lmAAouVxS3I8cQ2qCc2xNEF8Qm7Fl
pGg/sjvMACBRe5na9yGW2GaLJRL7yUqEKiOflYgRs2LcWwWEHFXGkM5UGTIFQhceA6+RQfvs
edEbQbyfd9UrrgLTSTR8ykbDlpGFlpkxEA3FPzDRALthrnNeua/R0JX3EHuRvwfvwWVXdOgM
voZTwquTtjjCqyiWVzNjYjO2DiW8msXwSo31whWUtk3Qw8GrPnfJK92S5KScrPTsFYHpGfMR
6SYQlKBpqDGnZRtTk7ON6fOz8Y9M43I8ZqEVyUs4K/t/pUOb8TWckmosL2EBqcYyWZ5sHYot
vQw8GT9ZwpNpnJXtdQvcO6thydfUU2kxDltsMwgOy0Q4XMZaLiM4+EtwgKfS38vg0Kmn0jI4
CM+EG7+RPJV2+NScsJD4tEjk02WFloRI8GnFtxKfBnAaK/lUOEAD9Ky70v82+V+yF+4f7F44
3111zf4v43VIAPW/Tb6GPSMg8VC6u9L3lEhnc3uwqCeSX2mZaBB9T8kL1iIg0Zqu+F/GLpGe
xDpRT2IvrjPLRN/k8YI6EyR+kK74n9B8QWKvB0U9gTxci58UfSPUC2pxkBizQvH/lsUT7p1h
uZcQidF8QzRbeQOa/wZQSwECHgMUAAAACADVjY5HeuIO56QRAADGTQAAHgAYAAAAAAAAAAAA
gIEAAAAAbmZzLXByb2JsZW0tbmtzK2dsdXN0ZXJmcy5wY2FwVVQFAANx8m5WdXgLAAEE6AMA
AAToAwAAUEsFBgAAAAABAAEAZAAAAPwRAAAAAA==
--------------090706020302080707010702--
