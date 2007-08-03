From: Stefan Walter <stefan.walter@inf.ethz.ch>
Subject: Re: rpc.mountd crashes when extensively using netgroups
Date: Fri, 03 Aug 2007 09:57:32 +0200
Message-ID: <46B2DFEC.7000409@inf.ethz.ch>
References: <46ADDFB2.9070709@inf.ethz.ch>	<20070731144824.GA15231@fieldses.org>	<20070802113255.d686894c.jlayton@redhat.com>
	<18098.39541.547557.132952@notabene.brown>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------090305070200030508070909"
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org,
	Jeff Layton <jlayton@redhat.com>
To: Neil Brown <neilb@suse.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IGs2V-0003ob-Hb
	for nfs@lists.sourceforge.net; Fri, 03 Aug 2007 00:57:39 -0700
Received: from xsmtp0.ethz.ch ([82.130.70.14])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IGs2X-0007IU-NE
	for nfs@lists.sourceforge.net; Fri, 03 Aug 2007 00:57:43 -0700
In-Reply-To: <18098.39541.547557.132952@notabene.brown>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

This is a multi-part message in MIME format.
--------------090305070200030508070909
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

Neil Brown wrote:
> I'm having troubling visualising the problematic setup.  Is it
> possible to get a copy of the /etc/exports file, and some idea of what
> hosts are in which netgroups?  Knowing that would help assess the
> appropriateness of various solutions.
>   
The attached file contains a synthetic configuration with 500 exports
that triggers the bug. Put some useful hostnames in the workstations
netgroup
in the enclosed /etc/netgroups, start the nfs service and try to mount
one of the exported directories from a host you put in the workstations
netgroup.

The mount should fail. Whether mountd crashes or not seems to depend on
previous mounts from the host. You may need to start with a truncated
/etc/exports,
successfully mount a shared path on a host, export the full /etc/exports and
mount another share on the host.

- Stefan


--------------090305070200030508070909
Content-Type: application/x-gzip;
 name="files.tar.gz"
Content-Transfer-Encoding: base64
Content-Disposition: inline;
 filename="files.tar.gz"

H4sICMvZskYCA2ZpbGVzLnRhcgDtnV3PH8dtxXWdT6HLBDDg5cvO7t71mxiuITRFACuVZKT9
9pWs5SqNTt8O8IxG4Nkbx0/zLzolZ3jIH4fz4c37Dz++etlv+/gd+/77Pz9+//jP3/+zbWPP
fY/N89Vm2x7Hq9f7qwnfb+8//Pzu9etX796+/fA//ff+t//5d/p9+GT/396/ebfnjwvY/6P5
j4/2t3G47D/V/hnjx2X2vx277D/X/pevtf9T9p9qf99jpf2fiv9z7R+xLWX/kP3n7v9jqf2/
m+w/1f62rbD/K/4fKf031/7j5aoAjP7bFP8n7/9rX2n/j032n6v/Tlf+33n/D1tp/0v/zdb/
27FU/jdk/6n2z5cDADr/v4fz//Clzn/Vfyaf/35p/3c+/z1V/+98/tup87/z/j/3pc5/6f+5
9r9iLf6/y/5z9d95aP93jv/bUvV/6b/Z8X+E8r/O53+ulf+r/2+y/tvX0n86/yef/9e50v4f
Ov8n7/9zpf1/bLL/XPvHsVT8V//PbPuPTfy/c/6/WP+nzv+59j8vxf/W+n8fyv8713923f9t
Hf/HWIr/S/9N1v++1v1f8d/J5/8S/f/K/76Z/js0/6G3/tf979b2P036v7P+33Kp/h/F/8n6
z9eq/+v8n2z/OBT/W+f/S+n/ofN/sv4z2b+1/WOt/k/V/yaf/2vd/xnq/5yc/x2b5r901v/X
Wvpf+3/2/l/q/vfQ/p8c/801/7ez/a9N9Z/G9j8Xu/+l/H92/r+W/XX/Y7L9Tf1frc//Y63+
f+3/yfn/YvOfpf8m6//NxP9b13929f93Pv8Xq/+o/2+y/fe1+r/U/z05/7tc9z8767+h/v/W
+z9P9f90jv/pqv913v/bWv1fsv/k+L/r/m/v/H+t+K/6/2z7r3X+K/+bHP9d859b23/o/YfO
9rdrqfvf6v+erf/tkP5rbP9rrfz/EP+brP9zqP7f+fzP0Pufnff/2DX/qfP+j136r3P+t8T8
vy/5n/b/5PqPr1X/1/3P2fHfpf8629/F/1uf/5fp/G99/of0f+v6j95/aW3/ofefWuf/S8x/
1P2/b2Z/W8v+2v9z7T9M81965/+m+7+dz/99rff/VP+ZXP9Z7P1n2X9y/rdE/6fuf36z+H/p
/b/W57+Z5v92Pv8Xu/+h83+y/Q/N/2sd/7dL/K9z/N9d9u9s/3Op+D9k/8nxf1tr/p/sP3n/
Z0r/Nbb/vlj9V/x/8vm/2PsPqv/Ntf+52P1vnf9z7W+H6f5X5/pP6v5na/2/WP1P+3+u/Q9T
/G+t/0Pzn1vbf7H538r/J+u//dD9z877/1pK/w3pv8n7fxuK/53tP/T+S2v7u6v/s7H9baw1
/0v2n23/pe7/DtV/Jts/Tt3/a63/Tf1fje2f51rzXzT/b/L+v3blf633/1L5v/TfZPu/XPqn
9z++D/2/Vv4v/TfZ/rlU/5/mP8/Wf2u9/yX7z9Z/i/Ff1X9n6/9N97862z/U/9M6/vuu/r/O
9l/r/q/03+z8b63+f+m/yfYPO6X/Ouu/LdX/2Xn/Xy7939n+i+1/zX+Ya/9rrKT/jk38Z3L+
d6yl/5T/z87/Ted/Z/0/TPM/Ou//tfq/1P85W/8fh+J/6/zP9f5X6/qPaf5TY/uPteY/DsX/
yfo/L8X/zvp/sfefxP8mx//F+L/43+T9vxj/k/6ba39b4v23L/d/pP9mx3+9/9J6/0cutf+l
/ybv/0P3f1vXf3It+6v/a3L+l2vxP/H/yfF/ifs/iv/fyv55hvZ/5/M/TvV/d7a/D/V/dT7/
x9D8t875/9D7T73zv133Pzvbf7H5r+r/mHz+75fif2f7n7r/0dn+Fur/aZ3/5ab5D43tP/a1
8j/Vf+fa/zTx/9bn/2HK/xvbfw/V/3rXf7T/W+d/Hpr/3zn+L1b/k/0n2/869P5T6/2/q/+n
sf393NX/11n/XWu9/yz7z7b/Uvc/h+p/k+2/1v2fof6PyfYPV/7fWf+NQ/qvsf1jrfmv2v+z
8//F5j8r/k/e/9uQ/Tvb313z31uf/6H+39b5/7nU/X+d/5P3/2L3f8X/Zud/rvO/s/0Pvf/R
2/4p/t/Z/nsq/nfWf9da/d/S/5P3/3mp/69z/n9p/mdr+++H6j+tz/9N+X9n+2+H+H9j+4/F
5r9p/sPk/W9D+7+x/f3Y1P/RWv+fev+p9f4f6v9tbP+0Q/X/zvpvsfu/uv81ef+H3v9prf9s
rfd/VP+bvP9T53/v/b/W/Cfl/7Ptn7r/2zn/303zn1vbX++/tD7/l+D/X/S/9N/k/X/p/Z/O
9o+Ryv8a2//l8J/6v7+L/e/iP73z/0P6r7H9X679nzr/TfafvP8ztf8b2//Y1f/bWv9vmv/a
uv5ju+r/neO/r6X/df9zrv0zXfc/Otvf17r/of0/+/y3pfo/FP8n2/9cqv9rl/0n6/9Q/td6
/6er/7vz/t9O6f/O9t91/6d3/B+a/9M5/x96/7Oz/WOt+K/9P9v+bqr/Nbb/vtj8L53/k+2/
2PxX5X+T9f+h9x972//S+x+N7X8sdf4fm/r/J9s/pf9a53/nofO/df5/6f2nzuf/uVb8V/1v
rv3z0Ps/ne1v7pr/1Tn/P/X+U2v7x1r937r/Odn+a+X/Q/nf5Pi/hfr/O+f/S9hf/P+b2T8u
9X91Pv+vTfd/O9t/3zT/uXX9Z633v3T+T87/bKn5nyn7T9Z/51L930P8Z/L+j9T7n63z/7Xq
fzr/59r/MvGf1vt/H+r/aWz/PKT/Otv/TM1/bV3/2daa/6j+r9nnf4r/dLb/cL3/0bn+c2n/
t87/rkP6v7P9D83/6V3/0fzv1vlfbrr/0Xn/R4j/tc7/Np3/nc//3VX/ax3/Q/bvfP4fmv/R
2f676f5f6/N/uN5/7Wz/I9T/3zn/X6z/Q/X/ufb30Pyv1uf/tdT9ryH7Tz7/F7v/pf6/yfn/
tSv/b23/per/yv9m298P2b+z/U33P1vnf4v1/8j+k/O/sen93877f6xV/9H+n7z/l5j//2X/
K/+fvP8Xm/8o/T/Z/qf6/1qf/0u8/635j9/K/i+H/zX/5Xuw/8s9/0DZ39T/Odf+cYb4f2P7
57WW/ZX/Tbb/WvMfVf+bnf+N1PyPzvH/UP7f2v4xtP9b1382vf/UOf4vNv9F+d/k/W+u/d/Y
/vum9z9b5/+n6/zvfP7vKf7XWv+l+r9b139C9u+8/3fd/+5s/5cb/0vF/031v8n7PzX/sbf+
X6r/W/O/Z+//tfq/NuV/s+s/ev+pdf4XpvefO8f/a635b9J/k+1/LvX+21D+N1n/LTb/V/F/
sv23tfp/pP8n67/tUv9f5/hvttT+l/6fnP/vpv7vzvv/WOv+t+w/1/7nWKv+J/tPPv8PV/9H
6/xvrfmPyv8m53+X+E9r/ZdD77903v++K//rrP/Wmv+p/p/Z9t8Ozf/ofP7npv6PzvnfqfO/
tf7fhua/d7b/OdT/3Vr/DeV/je2/H6r/9Y7/l+7/N7b/yz3/zu1/9X/Nzv8v9f921n9r1f+V
/02v/6TmP3Xe/4fm/3e2/5Vr6T/d/5us/xbr/1T/3+T879D+b63/4lT/b2P722a6/9k5/i+W
/6n/Y/L+Pw7x387x/1qr/0f1/9nxfyn9P6T/5to/zdX/2fn839ayv87/yfa30P3PzvF/33X/
r/P+D8X/1vpvM73/1dn+a/X/DfV/z7V/uPhP6/ifp/p/Out/0/zX1ue/XTr/W+v/Xe8/Nbb/
GWv1fyn/n33+K/9vrf9O9f+2zv/GUP7Xef9fJv7TOf7va+V/0v+z479r/3e2v681/0v6b3L9
50qd/533/5FL7X/N/5ic/12b5n80tv+11PsPh95/n73/zxD/66z/jl3zvzrrv8ul/zrbfzuV
/3c+/93U/99Z/y3W/yP7z7b/Wv3/yv8mn/+m999a6z9Pvf/S2P6Rh/p/Ou//cWr+U+f4v9j+
l/6ffP7vev+jt/1D/Ldz/u96/7d1/B96/6P1+X+F9F/n/R96/7u1/W3T/c/O5/841f/d2P62
a/5X6/M/df+39f4fu/r/Otv/XIv/Kv7Ptb8vxn+k/+fa/3DNf2mt/xZ7/1P6b3L8j139/53j
vw3Nf+x8/u+H7v81tn/sa9X/Zf/J+z/V/9V6/y92/0v7f7L902T/zuf/YvP/lf9Pzv8W6/+S
/Sfbf0j/d7b/vqv+2zv+6/233vF/Kf2/K/+fa3871+I/6v+ba/+x2Psvsv/k/T9S8/9bn/9r
zX+Q/ptr/zC9/9g6/zuG7v90Pv8P8d/O9j8O6f/W8X8/1f/VOf5vvpT+U/1/sv3P1P5vrf/1
/lNn+7un+H9j+5/nWu9/Kf+bfP6Hq/7X2P77Yvd/Ff/n2t+WuP+v+R/frP4Tqfc/Osf/te7/
Kv+bbf9d8z9a299d+X/r+s9Q/G+t/9fq/xX/mbz/F7v/qfrf7P1/qf+/s/19W8n+mv8/W/9f
S+k/vf83e/+fJv3X2P4Rmv/bev8fl+7/dN7/h+Y/tLb/2DX/p/P5v6+l/6T/59rfc1P/f+v8
by39J/tPjv+L9X+r/3Py/l+i/vdl/4v/zN7/ev+1tf2vXfMfOtv/3HX/s7P9X6z8R9X/NvHf
2ft/rfqv7D/Z/ou9/yT7z7W/x67+38b2z7HW/B/Zf679x7XW/X/xn8nnvy/1/ov6P2frP1ur
/qf671z729D8h872f7nxX7L/95H/mfo/Oud/Ecr/O9t/sfm/4n+T9f+1lP3V/zE9/ofmf7Su
/5y6/9/Z/udQ/0dn/bdY/Vf6b679LZa6/yP7T7b/sVj9V/afa//Tdf+3tf47XPNfO8f/Jd5/
0vynb6b/N/V/tN7/ttT9P9V/Jts/DlP875z/rXX/x2T/yfF/rf5/nf+z7b9vqv921n9r1X+G
9P/k/X8uNf9d8x+nx39T/0fn/G+t+d+6/zfb/pnK/zvbf1za/53j/6b+v87298X6v3X+Tz7/
D/V/tq7/xFrvf6v+Mzv+6/5/6/i/K/9raP83H3758dc3H/7l3dvf/vrqBe0/Mv8b+3tGPPbP
cXw6/90+zf/dZP8X//729t1fPv5/4MO/vv31/es//t2/2Q8//Om//MH/8Q/x8Q9/+F06vP77
/y2//8m//lN8/af8+k/7138aX//p+PpP59d/ur7+k23gb+D/fgMLMLACA0swsAYDizCwCgPL
MLAOB+twZAewDgfrcLAOB+twsA4H63CwDgfrCLCOAOsI5FBgHQHWEWAdAdYRYB0B1hFgHQnW
kWAdCdaRaGeAdSRYR4J1JFhHgnUkWMcO1rGDdexgHTtYx462OFjHDtaxg3XsYB07WMcA6xhg
HQOsY4B1DLCOgc4qsI4B1jHAOgZYxwHWcYB1HGAdB1jHAdZxgHUc6NAF6zjAOg6wjhOs4wTr
OME6TrCOE6zjBOs4wTpOFD3AOk6wjgus4wLruMA6LrCOC6zjAuu4wDousI4LhUEYB1Eg3FAk
3FAo3FAs3FAw3FA03FA43FA83FBA3NCKcGhHK4LBHUZ3GN5hfIcBHkZ4GOJRjDcU5M2hWkEr
QnHeUKA3FOkNhXpDsd5QsDcU7Q2Fe0Px3gIKMLQiFPINxXxDQd9Q1DcU9g3FfUOB31DkNxT6
LaGmRCtC0d9Q+DcU/w0JAEMKwJAEMKQBDIkAQyrAdiiT0YqQEDCkBAxJAUNawJAYMKQGDMkB
Q3rAkCCwAZU/WhHSBIZEgSFVYEgWGNIFhoSBIWVgSBoY0gZ2wGQGrQjJA0P6wJBAMKQQDEkE
QxrBkEgwpBIMyQQ7YX6GVoSUgiGpYEgrGBILhtSCIblgSC8YEgyGFINdMOWEOSdKOpFmcKQZ
HGkGR5rBkWZwpBkcaQZHmsGRZnCDaTRaEdIMjjSDI83gSDM40gyONIMjzeCwLgALA7gygFYE
awOwOACrA7A8AOsDsECANIMjzeBIM3jAYgdaEdIMjjSDI83gSDM40gyONIMjzeBIMzjSDJ6w
foNWhDSDI83gSDM40gyONIMjzeBIMzjSDI40g++wJIVWhDSDI83gSDM40gyONIMjzeBIMzjS
DI40gw9YZUMrQprBkWZwpBkcaQZHmsGRZnCkGRxpBkeawQ9YOEQrQprBkWZwpBkcaQZHmsGR
ZnCkGRxpBkeawU9YC0UrQprBkWZwpBkcaQZHmsGRZnCkGRxpBkeawS9Y3oX1XVTgRZohkGYI
pBkCaYZAmiGQZgikGQJphkCaIQyWrNGKkGYIpBkCaYZAmiGQZgikGQJphkCaIZBmCIdVeLQi
pBkCaYZAmiGQZgikGQJphoBUAWIFyBUwWEArgmgBsgUIFyBdgHgBaYZAmiGQZgikGSIhK0Er
QpohkGYIpBkCaYZAmiGQZgikGQJphkCaIXaIf9CKkGYIpBkCaYZAmiGQZgikGQJphkCaIZBm
iAGJFloR0gyBNEMgzRBIMwTSDIE0QyDNEEgzBNIMcUBIh1aENEMgzRBIMwTSDIE0QyDNEEgz
BNIMgTRDnJA7ohUhzRBIMwTSDIE0QyDNEEgzBNIMgTRDIM0QF0SpkKUimIo0QyLNkEgzJNIM
iTRDIs2QSDMk0gyJNEMaxMNoRUgzJNIMiTRDIs2QSDMk0gyJNEMizZBIM6RD4o1WhDRDIs2Q
SDMk0gyJNEMizZBIMyTSDIk0QwaE+GhFSDMk0gyJNEMizZBIMyTsSYBNCbArAbYl4L4EtCLY
mQBbE2BvAmxOQJohkWZIpBkSaYZEmiF32GqBVoQ0QyLNkEgzJNIMiTRDIs2QSDMk0gyJNEMO
2D2CVoQ0QyLNkEgzJNIMiTRDIs2QSDMk0gyJNEMesCEGrQhphkSaIZFmSKQZEmmGRJohkWZI
pBkSaYY8YY8PWhHSDIk0QyLNkEgzJNIMiTRDIs2QSDMk0gx5wbYl2Lf0Dyt6pe//3P/75t//
+vbdh/evvk3/73FskU//t8f+qf9320z9vzO+H79cAHr9T7//448/v/+PX3/54d3ffvj17U+f
Vv3T+3/77ef3f/70r+9/++cP7968+emXP7/55S9/+sOXH/vnHzv14/j846B+nJ9/nNSP988/
3qkfj88/HtSPj88/Pqgfn59/fFI/vj7/+KJ+/DGR+ewlG/fzcjLOy+x2M+P8zG5HM87T7HY1
43zNbmczztvsdjfj/M1uhzPO4+x2OeN8zm6nM87r/PY657zOb69z8myrw43zOr+9zjmv89vr
nPM6v73OOa/z2+uc8zq/vc45r/Pb65zzOr+9zjmvi9vrgvO6uL0uOK+L2+uCjKkVVDmvi9vr
gvO6uL0uOK+L2+uC87q4vS44r4vb64Lzuri9Ljivy9vrkvO6vL0uOa/L2+uS87q8vS5JLVdi
jvO6vL0uOa/L2+uS87q8vS45r8vb65Lzury9Ljmv22+v2zmv22+v2zmv22+v2zmv22+v2zmv
22+v28kcopIIzuv22+t2zuv22+t2zuv22+t2zuv22+t2zuvG7XWD87pxe93gvG7cXjc4rxu3
1w3O68btdYPzunF73SBz10peOa8bt9cNzuvG7XWD87pxe93gvO64ve7gvO64ve7gvO64ve7g
vO64ve7gvO64ve7gvO64ve7gvO64ve4gayZVNOG87ri97uC87ri97uC87ry97uS87ry97uS8
7ry97uS87ry97uS87ry97uS87ry97uS87ry97uS87ry97iRrdVWs47zuvL3u5Lzuur3u4rzu
ur3u4rzuur3u4rzuur3u4rzuur3u4rzuur3u4rzuur3u4rzuur3u4rzuur3uImvEVSRmq8RP
mZisE29VKN7ISvFWpeKNrBVvVSzeyGrxVuXijawXb1Uw3siK8VYl442sGW9VNN7IqvFWZeON
rBtvVTjeSE98gAVNLB5kQXriAy1YavFgC5ZbPOCCJRcPumDZxQMvWHrx4AuWXzwAgyUYD8Ig
GYYVxDCSYlhhDHOWnj34jPTEQhlGsgwrmGEkzbDCGUbyDCugYSTRsEIaRjINK6hhJNWwwhpG
cg0rsGEk2bBCG0ayDSu4YcGS3Aflkp5YgMNIwmGFOIxkHFaQw0jKYYU5jOQcVqDDSNJhhTqM
ZB1WsMNI2mGFO4zkHVbAw0jiYYU8LNmugqetgPTEwh5Gcg8r8GEk+bBCH0ayDyv4YST9sMIf
RvIPKwBiJAGxQiBGMhArCGIkBbHCIEZyECsQYjvb4fK0uJCeWDDESBpihUOM5CFWQMRIImKF
RIxkIlZQxEgqYoVFjOQiVmDESDJihUaMZCNWcMRIOmKFR2yw3VZPuxXpiYVIjGQkVpDESEpi
hUmM5CRWoMRIUmKFSoxkJVawxEhaYoVLjOQlVsDESGJihUyMZCZW0MQOtvPvaf0jPbHAiZHk
xAqdGMlOrOCJkfTECp8YyU+sAIqRBMUKoRjJUKwgipEUxQqjGMlRrECKkSTFCqXYyXahPm2o
pCcWTjGSp1gBFSOJihVSMZKpWEEVI6mKFVYxkqtYgRUjyYoVWjGSrVjBFSPpihVeMZKvWAEW
u9iO6Kclmu2Jfpqiya7oYixOMhYvxuIkY/FiLE4yFi/G4iRj8WIsTjIWL8biJGPxYixOMhYv
xuIkY/FiLE4yFi/G4sb25z8N+qQnFmNxkrF4MRYnGYsXY3GSsXgxFicZixdjcZKxeDEWJxmL
F2NxkrF4MRZn74k8F0XYmyLPVRH6rshzWYT0xOe6CHtf5Lkwwt4Yea6MsHdGnksj7K2R59oI
e2/kuTjC3hx5ro6QjMWLsTjJWLwYi5OMxYuxeLD3lp6LS6QnFmNxkrF4MRYnGYsXY3GSsXgx
FicZixdjcZKxeDEWJxmLF2NxkrF4MRYnGYsXY3GSsXgxFk/2Dt1ziY70xGIsTjIWL8biJGPx
YixOMhYvxuIkY/FiLE4yFi/G4iRj8WIsTjIWL8biJGPxYixOMhYvxuI7e5/zudBJemIxFicZ
ixdjcZKxeDEWJxmLF2NxkrF4MRYnGYsXY3GSsXgxFicZixdjcZKxeDEWJxmLF2Pxwd4tfi4X
k55YjMVJxuLFWJxkLF6MxUnG4sVYnGQsXozFScbixVicZCxejMVJxuLFWJxkLF6MxUnG4sVY
/GDvuT8X3UlPLMbiJGPxYixOMhYvxuIkY/FiLE4yFi/G4iRj8WIsTjIWL8biJGPxYixOMhYv
xuIkY/FiLH6yMxeeoQukJxZjcZKxeDEWJxmLF2NxkrF4MRYnGYsXY3GSsXgxFicZixdjcZKx
eDEWJxmLF2NxkrF4MRa/2PkfzwAQdgLIMwKEnAFSjCVIxhLFWIJkLFGMJUjGEsVYgmQsUYwl
SMYSxViCZCxRjCVIxhLFWIJkLFGMJUjGEsVYwthpNM84GtITi7EEyViiGEuQjCWKsQTJWKIY
S5CMJYqxBMlYohhLkIwlirEEyViiGEuQjCWKsQTJWKIYSzg7GekZjUR6YjGWIBlLFGMJkrFE
MZYgGUsUYwmSsUQxliAZSxRjCZKxRDGWYOdzPQO62Aldz4gudkbXM6SLntL1jOkiPfEZ1MVO
6npGdbGzup5hXey0rmdcFzuv6xnYxU7sekZ2kYwlirEEyViiGEuQjCWKsQTJWKIYSyQ7Me4Z
GUd6YjGWIBlLFGMJkrFEMZYgGUsUYwmSsUQxliAZSxRjCZKxRDGWIBlLFGMJkrFEMZYgGUsU
Y4mdnV74jC8kPbEYS5CMJYqxBMlYohhLkIwlirEEyViiGEuQjCWKsQTJWKIYS5CMJYqxBMlY
ohhLkIwlirHEYCdpPqM0SU8sxhIkY4liLEEylijGEiRjiWIsQTKWKMYSJGOJYixBMpYoxhIk
Y4liLEEylijGEiRjiWIscbBTXZ+xrqQnFmMJkrFEMZYgGUsUYwmSsUQxliAZSxRjCZKxRDGW
IBlLFGMJkrFEMZYgGUsUYwmSsUQxljjZCcPPiGHSE4uxBMlYohhLkIwlirEEyViiGEuQjCWK
sQTJWKIYS5CMJYqxBMlYohhLkIwlirEEyViiGEtc7LTrZ9w1O+/6GXhNTrwuxpIkY8liLEky
lizGkiRjyWIsSTKWLMaSJGPJYixJMpYsxpIkY8liLEkylizGkiRjyWIsaezs9Wf4OumJxViS
ZCxZjCVJxpLFWJJkLFmMJUnGksVYkmQsWYwlScaSxViSZCxZjCVJxpLFWJJkLFmMJZ19B+B5
CID0xGIsSTKWLMaSJGPJYixJMpYsxpIkY8liLEkylizGkiRjyWIsSTKWLMaSJGPJYixJMpYs
xpLBvknxPEpBemIxliQZSxZjSZKxZDGWJBlLFmNJkrFkMZYkGUsWY0n2XZTnYRT2ZZTnaRT2
bZTncRT2dZTneRT6fZTngRTSE58nUtg3Up5HUthXUp5nUth3Up6HUtiXUp6nUkjGksVYkmQs
WYwlScaSxViSZCxZjCVJxpLFWHJn3+p5HushPbEYS5KMJYuxJMlYshhLkowli7EkyViyGEuS
jCWLsSTJWLIYS5KMJYuxJMlYshhLkowli7HkYN+Neh6OIj2xGEuSjCWLsSTJWLIYS5KMJYux
JMlYshhLkowli7EkyViyGEuSjCWLsSTJWLIYS5KMJYux5MG+YfY8YkZ6YjGWJBlLFmNJkrFk
MZYkGUsWY0mSsWQxliQZSxZjSZKxZDGWJBlLFmNJkrFkMZYkGUsWY8mTfU/veVCP9MRiLEky
lizGkiRjyWIsSTKWLMaSJGPJYixJMpYsxpIkY8liLEkylizGkiRjyWIsSTKWLMaSF/u24/O4
I/u64/O84//HE1/p06dPnz59+vTp06dPnz59+vTp06dPnz59+vTp++6+/wRHeqoAALAEAA==
--------------090305070200030508070909
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
--------------090305070200030508070909
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--------------090305070200030508070909--
