From: "Felipe Alfaro Solana" <felipe_alfaro@linuxmail.org>
Subject: Re: Bug: 2.5.47 NFS reports giant filename in readdir
Date: Tue, 19 Nov 2002 21:17:16 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20021119201717.10566.qmail@linuxmail.org>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="----------=_1037737036-10426-0"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from 205-158-62-68.outblaze.com ([205.158.62.68] helo=spf0.us4.outblaze.com)
	by sc8-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18EEoK-0001m7-00
	for <nfs@lists.sourceforge.net>; Tue, 19 Nov 2002 12:17:28 -0800
To: trond.myklebust@fys.uio.no,
  "Felipe Alfaro Solana" <felipe_alfaro@linuxmail.org>
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

This is a multi-part message in MIME format...

------------=_1037737036-10426-0
Content-Type: text/plain; charset="iso-8859-1"
Content-Disposition: inline
Content-Transfer-Encoding: 7bit

--- SERVER-SIDE ---
===================
Name: glass
Pentium IV 2Ghz
512MB RAM
RedHat 8.0
2.5.47 Kernel

/etc/exports:

/                        192.168.0.0/255.255.255.0(rw,async,no_root_squash)
/data                    192.168.0.0/255.255.255.0(rw,async,no_root_squash)

--- CLIENT-SIDE ---
===================
Name: teapot
Pentium III 700Mhz
256MB RAM
RedHat 7.3 highly patched with RPMs from RedHat RawHide
2.4.20-rc2-ac1 Kernel (this time without the patch you sent me)

/etc/fstab extract:

glass:/data             /net/glass/data         nfs     noauto,users          0 0

Commands used:

# mount /net/glass/data
# cd /net/glass/data/Jpgs/Jpgs11
# ls

I ran "tcpdump -w capture -s 8192" just before issuing the "ls" command, and stopped it just after the "ls" command failed.

Please, don't hesitate to contact with me again for additional information or help :-)

Sincerely,

   Felipe Alfaro Solana

----- Original Message -----
> Then I'll need more details on your setup. Server type, mount
> options,..., and possibly the raw tcpdump output of the last few NFS
> calls just before you get the 'readdir reply truncated'
> message. Please remember to use a large value for the snaplen
> (e.g. '-s 8192')
> 
> Cheers,
>   Trond
> 

-- 
______________________________________________
http://www.linuxmail.org/
Now with POP3/IMAP access for only US$19.95/yr

Powered by Outblaze

------------=_1037737036-10426-0
Content-Type: application/octet-stream; name="capture.bz2"
Content-Disposition: attachment; filename="capture.bz2"
Content-Transfer-Encoding: base64

QlpoOTFBWSZTWemhURgAKov/////////////////////////////////////
////////4BW/CwBt8FVYDp8UigoVO3x0iQDY2hNvZwpkAAAAABQCm973uAJw
0RCBPVJ6j1PSYm1GQ9T0nqHk1PZNHlTaYJPVGzVP0mp5lTbQpmo9IPSaYjbV
A0HqABoND1B6gNNDyTQGQGgaaB6TI9TQyAe1Tym1BmkPU9T1NP1NqQiRU2w1
NAxGjVT89TRpqYaNNBpoxTUjR5RiNNGg9TJo8poDIAAADQA0AAAAAAAAAAAA
AAAAAAANEYTVMiBpPSIekxBoANABoAADQAPUNAaAAAAAAAAAAAAAAAAAAAAA
AAAABp6SITTQFNNU8oeoH6o9qjyQ/VDRsnqnlGgbUGmg09QAANGE0ABoAAAA
ADIAAAADQAGjQDR6RiAAANABVQmQaBoGh5pGo0AMgDQ0aAAeoGhoBo0aNqAD
QyPU0AeU9CeJpqaPUND9UGQPSaHqHqHoj9U8p6HlGkDNJoyZN6pmmmjam9Jp
Rpk0EiRAjQCaEwjTRMATaBKfgmEyaNCaM0aaPVNJ7TUZqNMKPUeoAAAA0aG0
1A0PUHqNAAGgAGgD1APU09TQAANA0BbhxZc3U2e23m+3/mgeeej9EfXCx5Pm
Dri+HQZp5MZyRL4ADrAaBISkBQIX+QD8loSR0GJJekAwLWA2k2A2A2dIYhBN
gCPP994X2+rakUpAVsYwbaYjYNCgbYlFVVNVcUm4Axi2wBfgwAuREPe8DjaO
u0PZa3b4eZn4rS4udbsty2ycC1kXMzsWv77+JHbTN5lWjzP8DPhIIw7NTy/d
UMUNrncn0c3w/Q+T+KwxjqSO6TRwVaqu+6joFvATTTW0jfDMDXtH5wyEpZ+k
hG24K15FCFKxq0dzUl68JeexCjJkk14hJVdVL15Z1KTQsSGqBxxxxzZ57UNF
TlXXbK2ObS3xxazgsYtu/Ro0aBt1bRsR58u+exWkDHKfJfkLoKOkTaglTKjc
+pSUGtgZknu0iJNVBjvP02HIbqV63A/rckcCdd6jabfvTXqMDg4L5CEImQhC
EIQkuljYJbY07y5tQ3tlalaphjNTLtHCN6GtGjTmZTb56mB60W8jOecem3Hn
np12wxdWPPPPPmvYMZfCvBVqyH351OTJfccccctXHM/LdYgaPsLYuZZuYbiV
tI5VVVV1GhWrT6qtVWnTZRYSSSSSSSewz6S5GZqsF2FEnu4tDM04tq486oOn
Jpo35tZFFGRVlRo00yLRaquIXcTEeuXCjoS6s+Mw+qSRmwAM0EUBZoEhAHzF
CEJLfgZAJikkJIbR7wBpCQuSHgJCAQIFqZG0ACQQpKqn8b271dnQ2DHT+mz3
m+6m5j9JsJucAFt6rR7yeru/B4xMdNbYiCiOZk+ahRY/nCP+Vfke5z0dH6SQ
SJd9uk8ko1uFdAPT11so7gACUTw8kIauktp/DmFUPL2ZxA0mMl1J5RZd31H1
qRbq7fakvZ3HQskTwfVL2EhnB5zkKBz23+yN941IxY8GggPvS0ySsTfNS0TR
lTVkqSZOj+pLVqjlMtA2BUi4MLUlhLcGOZX92MxYjdP3LtQrX+9h6fbNznfn
Vw7x5KGiXrGVA3C1/2ynzgghs0aiDZtw2KWUp06+nTvLm2XiQoRRRRRY8UUh
h3FoRmI7YodU3DPFuCCbqiZ1lF8JWnvEFUMaq4z+Eq3BYf23dBzWfz0fQZ6P
Yx8GNGjRo36yb3i73zpO0k7vd6/0dryG8w91vf4wNv/P9bChV+ak9FaHz+un
GtGdeurmxVgMEKdKmSSJdpAoO9fVr8IcM2jOuiXMSfKS7EABi93uKdPAl40q
XKlzkuXz+JlOAvvtxVxMx90WL/1bhaTx3uWx5XQX9fXu91d738NjtsD6Bb3w
k8ez6yZLIqaim+NHJjElkGI45gEKsxuW/gAAxRZxnEQIGjKt/TWrcyJFvby+
5lwJes6WVjY6wIDKmWmFsNOCxIYAVBAgRF8jQAIAkJL1ACYBCQkB1n+eAwEg
M5oBIDzhdiUgSF1O0CBpNAUiO8CBAJKGhJJKgBggO9AaWqAwQkMQMC8AxJKb
QhI9UBge/EDsQxCQxDoYkkAXxpC6KRiRAGoITPd2wQ4ggZaIVZSTIFEBA0DG
Jib+CBAggQxjbbWo0CQ2IENpIE2hAmwEL3YnXghB+uAFAAVEAAMjJgyPx0De
R9C+nzmnzsx2ReDVwMhRIqQACYgBdQv4gAGIBJSk/o997b6T6WoCoqeqhDaU
gE2AMCtt/KM1EFCCgA2YxSA06JCbSTaCiITZARCCBCBIBCBIIQhAABCBKASQ
AlAIISbahIEEBCBKAiEAQIQRAAkhAJCAQiBMShUEoTAEbtpJNgENCmIGkEmC
JMENo98RRVFFBJSqcSkiYSEhQBAgAEIAQIgBJEIQbmKpIhTKDAhpAhAkIabG
Nk2CIYJsEpMBDaSUAQccicuTyPU9T1bfT+0PceRitmTneBIvMQJYCCBCVKaL
/thFk5SEYqEE2kkDbG8kCIpbgBtNMBxMyyiSdISoUSQJkpSRTcbHO85+DrHw
vsYY98t+hJgHGA5IGAwibBsBobKqoQ2OQEoG4SUmkKUiURJEmDyTiJ5PQ5HR
/C7D+H07tloF1iVrASUE5ufwRCdDnCooJDnLSnQISZMZQ5MaJkQSaoRKju/4
vf/v+nWKyvIjFdKAbQZQtiJLuHWV9uiRSCE2h1OSmwGxDoKFNtgDXkilCiSJ
YARQXQdBz3Pc5wuFwseHR0ljUMwaoGaMpJ0ToYTYe9TpSIIDzXQzshCdLCkT
RWFfE4fD/QprqVY0pSZDJDQSZKSYQ3KFIkI0NDvsG+31lS0nYxsCTRCFCMDl
F2aFDaiRNw5TQNtTkRweDwOBuqqsPN5vL5vNqAPxUvDHYxe3MR+QJe8HOjzX
xqUsNXVx58+fPnyXCtEr0AQRDOfSQlJLahhNSaCXL5/C4Xq8bmb3e2W2gWi9
GFEmmTcBIGZiJ0U0UHMH+N/FOYVq3NzVo2wcRv+M4rZ3lbLY4nNhETUkTqpc
RJI1KobwVauKpPjN5w++3u93vA53C+FjyohTKBflohdYqlurCuiJTfyXRBZ3
8SQpMSeVx0tsFdxgtWqUtwQcLJPjins8iWDCsp3PaxnTb5RdMDbTcscSy4Me
Zhy10umJVFLCo9FS/ep5ylM0M2ekRhraUDSFU51pSJVJYSbCp0RUOhzhohzR
6OqI9ISisz0iEhnklBDtJ3iwdtnF9VRDatK3rrriIiIh5qslU0G7VXK4iUmO
5FdaEKqUtvu0Ot6yXTaru/risc3upNzTEaTg336NpdgkzJleQg9mq7e7sM19
Zu4ikQ0REpWLsrNd4Rio1tUpCnatUabIloWrTh6NRmd4E0qiiSsTWHWdEaEo
i2KJSkRFIhfcvwyZ3gYEYFiBAoR9VVTzKNCrKxut1w4iRCwo4USiR0bICFmG
Qia0ZnnaLLgldddZdflLZs262wtuwYD4PHdx42+2y5ZMreXDbabG9tWhqWTG
f2EIC5h5XREVkABExCqMDANyAdkSc3dFMzVVVCxhgubZmZXMgFVVQBTBMzMy
ggshj2bQUYgY0DFx01PNrmtQX771vzPutdlu6WdaMSuvCIhxqZa58mbdOuM1
8Jw0aVNSxX3WHM7vNko22ohtt3NhLZRsJzpJXY8Uqh5nTfmpjFYpxZsV+FLM
AQRnIxCFuqOEgWV32uxHT3Y3IdDbDM2gKtM2ZjjjRTEWUbARa9eZl0bAG20x
KsuWm222mDbfMzMSmGchMBBsNtOs1pRSAS023WE1Mxrl9HTtczNtKUpSlKUo
02wLmw13WXlI1780qt+tMms3pwYWEBw6WcThKgEa+7zvhsvDIpu7KNdpOBsb
E4r8cJdzEs2U717Tv000zqRrMWCUVMkymymSSrYkmxdiXcUxLKpAiwUDEUxN
ZkUynNZhDRKVZOowMbE8VZ2MOlZvSuS2FJkF/bDN/ji9eybMs7ByZJAiupX0
sNldwLO0NIlhxPGCw51SkVy+IpXDElWzbxFpXc8B5FfilKXqikUhAgSFCv2t
05VEbC5uEtWlhsbbRWtdvVze0aimUE0skZEQpOTLzQfam5oyY8mXJKijLLR0
qNLR0tK27gzHLFbFGC/bW20rWuattvRJugIjcI1S8ZtenRDxC1FMQ5KDExiY
xMYmPFCtwwphkoOS+dPF7rdZ+37na6txhoptc+alaapTNppZUrTTYyk3NWWb
RygjUvTB3uS+jUiYzcCkkTq5o6E8XCaUkK3d4ZMMeKaUnoWjRiy6MNE66LLt
NDlBK11W011VyrTOY4bGjTYZzQUsQ7tdkowXdPBh0+UIAMDEkhsBAGDDnZLc
N8opnhySY1lIUVbpbxnpCiswQrMgRmCLHEAHd3ochVezJZIjTp036C/I8MTw
w0WUJabnROQsxWSo0a0OEQhIBHlQzhAKHDGMoYo+Ik1l5eVsOXk7PpMlOYqW
EopVEtQrETLlQk1AMU5nIG6pO4+IhHkkxQyIEkpQQCUm1DBqQIqGQIqq8W9i
qzKdiSV12WRDWdU1adl2d6WXClkxlo5A8fidESv379yE02mfJINEDxmHrmI2
I0lCOnBNgcPNGELLkWbF3NzcDolCJoClZ+fsO5JRt+n3+v4HrqqubEfASDVA
PMAhKc2/b+54/h4urstfX1+Lbb5Xvf0sYHdoaR/Qho3e8ers9rLVfYb+dDiX
YbTFi0fdfX66SWug6KMYFdfSPXnonpIiLcqB9ippWOCk2d7NtWyWIwslb6jI
M1sEC78teIC1eXZFiiA5iLPcpJUIOWVGy0QVVXT1vWezGLlC50mwkzhtbX0F
gyM5Vt7wb8S2ytuwtXodtxbdr3vjl8lt537/oRHsd6dAFOfTDykucRgjBLEt
sAZWj0Kuh3LPx49i1SzwUwEKQFtEsSQhDHJW2UAM10NoNNu4RADZoCMMMMwi
ALpgRdtWws0KbMiJFqIByIKgAiy4oaIDDQKjqhBzEFOqFaKas66kl9l7jgYz
jYrih8dpF3qczU53S4vK7PlZlzGgwoN5fSU6OyM/rVTo3SMOFDAqsAqpqqzw
A3NIAdPxqOT23i3LntejKUOPrEKIfX5evz+h5vF6FdjbbeRAd+lvb8dTcd8B
upzShKnq7SlThVSlIVTG5SgkxHgM70HcUiF34lFXT6nfR0LngX+gLqWoJYzy
8ZjMFup5N69iw1O2/5Nevai+q/BJV5kCvexSZfdFF/DgouZteU4KSVsrtVMs
dtFttttlk7JYJTlOuy5lwfHEGa1KI2DZ5nPInjz+yzS/fv38uXL11dLYeI0c
7DovKxjoHkohSnZTetpy3e6JKnykFalXhWS5i0Ll22MUXMssbyXwMnmY2Zg5
nm03rkXKUXWlXe2UywJ0nI8vxNfuPLy7Td7zlkRmCWw6sEeUZfMRPOiYtEIn
mPRicmozps6YFHw1Jo3YSJlqLJCrqgnpKkCRUIFc3olpXaQ4RYcctOUjptIz
FqUluZxLcfA4Rr7ezHlMpLWFlJSw6GiGWY+xSfUS8ISyJZbOVUX5gaF/EbFF
fEMhn4Kvtpdt0qVIEtRtpCbAbTaL2dfsAQduMvWqkszZJCs1TbbaqsbtQEK4
lneGSh2lpx5myQxQHDQiFwhAvPFfv1zw3tDu9LZpLGG+7Pi8nkcjs8xZWPPx
CWbJA74NjaW7ZNhROd80KEJU5ANP2a47OzcMrflMl/9C7CRB5nX6/ez13Z7T
a7WaFtVnCBQ3jDMzicgoCcjKHnbVU61cawyyywkZ6LoF692Aldr09HircWpa
dJxh48EOt1QwLvHKzh0Hst/Q8xIFegsNaoVFME0nhCm1SqmRXrcQrrNh8Tcx
nHvwXOsY0rBhcQV2pZxfMieczH18Rd0yuXkTWgLOJliNAxu/m0JUXMpSYlkN
HS7KoVqWU3TVhQrUaQJAlZZF1K1JQQlsUoGSJX+0hF5rSqFr76Zv1MvHRS3K
VdLfCR2vV6vX1L3ie0zc7sTcbLUzA7mXFWnDbWc2nFFVDVQqCKd0KjerreDU
Bqd7gw30tziNpgWqGmGxC0hIoEW7o3Ug6bSJHcQQAQJhCsqgLhXQQSXj2m92
Fiwnb1EncHwEGhKmIwgY6VwS7ZdJip1hXjD25mFOdn3C/MvrKdAaN0lTwcwO
OkkCV27wMKA0tHAOGHQ4RxKQ5AvW7jKLxzHdXedX2Xde18XLlwByPWaeXCc8
DabbP3u2oQRpaYuFzyAJtAatDcjSNHg8uRtUhdarb+FWUCw1U5M/tN05l9GX
a3Jlw5EWX4oleMm3K5DdMyl4C9GYkvOsxO4i5LMpEfMgGps9/uba95ixIlrY
0dPDmS2aT1agORblSoCow4sqlTEQ7pIkqyJyqKJOUNZ4lJZ6lMmlc3wVKUAI
IOSlQg02ypQrCgqmQnFwk0pgUJNsBpNMCgYkXIgp2Fk6p1oKSafH1cOHOM8A
v9EJNGyuq7s0ktLKZukbBl1asXm+N2yuW+Hm1z2Nai/jvNbFHiFRUIegQWsg
E4ACUcEXGASACQhi1ACAWmnaWzptp2vb9YzbB8wEkXiABQhEoBmckkCXeExb
s0UQj4Qe8ArFLSFFNCJXrzdYEhZqISLWLSZs7ZoluAlo+KzUkVuoaNoIFqcq
iZs0lSXWIyArhg6NCvMvussIG1cjcXlFwoFuht6E4LoriMZPAyQ1Wlo5b1p1
i21FaC5TAAEDB7AzRLFSWoW7xeKIFuDOOCgGLSvUnfpXwzS2jh17mpKDW6St
8hITS2VxopjFfvRGiPNpu1cUaWx0KlTkA8by+dqZ+jYli0NNbCZMy5VotgIM
Eaeb68CSRj2aWZVk6RFK2hBQLV0gDQyUKQjbQzimIqMKFXfWLEbohYgZ2JHG
CB5CRiRwFABqiIhD18HwODMaUQFAELKAQrb0CFnmx0228gxb2CBTs3J60AxB
SOdZcu6WPTRUCr2e+8j2Gysu3cJtg3jbbYu6Of7qqrUyZ29zU2ApQgK+BjMQ
WCGcniJAhlyjGi8JmtYORxOo7BhZGIwjkZ5DJEAlNjaVeatLF3aOqWysl150
AIRy4QgzPRuc7WPKiA0atzQDqwAhH7Ukp2ez6/H2WgH9YbcbPA4Oz2jq/Kd2
vvv0IUy4lOWpicwzZYybGea3DQHjKKAoorVQ2xxrHaXZZZx0EFAEWWUUK1et
167diwefc+MEHFnOZEQTFzBCnP5DhykMbetvd/vOJvNbvN9cuel/TTNTttTw
t5NgllkAnGEC2wAVVuJ9LNFmUrbm+QnrV0pQaLqi0HKPXtO5eunTp1kMh+QB
AqDN3wACqunQi/Qj4bKtBAmwq2GILZtFQigQiR6iiikqkf1lTCZg5ypYhLr0
yEdh7CE9rabxKn6Ndf3SsTIwokVVuZnRlACKpNG95ZosqAEABGSIGJmHW0rt
27h0zYCnmK+ozbxy5iTVdzoAmObAFtxWm5jqJ3kqP0PI12Ji+L/uLk7iaBAP
hrgSBXAA9rYV3CPny1CZOanJQGM5YNANXCpWLNXSggSyDMzNfnJ7jGLWoZZf
v80vOGMob02c7HZZfLZcynXj2eqHmYfQ2xaoECmgASO0gCsdUNAt6+iBmL4x
hGPzMZEEO/1TW1VQ4BAkpy6jAAQAMDR0XE0U8xQ0NJTLzE5YWaVP7vNLb7LZ
5bWGaqqqqzTSYzdxWbPr1FI6lkxVQKqDBfuHD8fTNqKGZmdnDgwYM17CqvVn
KUojfAiI3j4XO6PP53advZXliG27gHQ6PG7bg8yuuyIbxBEAc3icPhzAPrXS
wBsfdiIjDx9zuO12/c1V4XDM6H0Z62trdh422wtGNu5Ey//i7kinChIdNCoj
AA==

------------=_1037737036-10426-0--


-------------------------------------------------------
This sf.net email is sponsored by: To learn the basics of securing 
your web site with SSL, click here to get a FREE TRIAL of a Thawte 
Server Certificate: http://www.gothawte.com/rd524.html
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
