From: "Iozone" <capps@iozone.org>
Subject: An interesting performance thing ?
Date: Wed, 14 Dec 2005 12:22:38 -0600
Message-ID: <00b901c600db$5d374960$1500000a@americas.hpqcorp.net>
Reply-To: "Iozone" <capps@iozone.org>
Mime-Version: 1.0
Content-Type: multipart/alternative;
 boundary="----=_NextPart_000_00B6_01C600A9.12598ED0"
Cc: <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EmbH9-0004zq-S8
	for nfs@lists.sourceforge.net; Wed, 14 Dec 2005 10:22:51 -0800
Received: from vms040pub.verizon.net ([206.46.252.40])
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1EmbH8-0007Wz-H2
	for nfs@lists.sourceforge.net; Wed, 14 Dec 2005 10:22:51 -0800
Received: from cappsnc ([71.96.135.143])
 by vms040.mailsrvcs.net (Sun Java System Messaging Server 6.2-4.02 (built Sep
 9 2005)) with ESMTPA id <0IRI004X731Q5KS8@vms040.mailsrvcs.net> for
 nfs@lists.sourceforge.net; Wed, 14 Dec 2005 12:22:40 -0600 (CST)
To: <neilb@cse.unsw.edu.au>
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

This is a multi-part message in MIME format.

------=_NextPart_000_00B6_01C600A9.12598ED0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

Neil,

    I think I have discovered an interesting performance anomaly.

    In the svcauth code there are places that do:

       hash_long((unsigned long)item->m_addr.s_addr, IP_HASHBITS);

    Ok... That seems reasonable, but then again...maybe not....

    I believe that s_addr is an IP address in Network Neutral format.=20
     (Big Endian)

    So... When one is on a Little Endian system, the hash_long
    function gets handed a Big Endian value as a long, and
    later, via the magic of being a Little Endian system,
    gets byte swapped.

    Step 1. 192.168.1.2 becomes 2.1.168.192 (byte swap)

    Step 2.  The 32 bit IP address becomes a 64 bit long when
                 this code is compiled and run on an Opteron, or
                 an IA-64 system.
                 2.1.168.192 -> 0.0.0.0.2.1.168.192
    Step 3. Call the hash_long() and get back a hash value
                that is IP_HASHBITS (8) in size.

    You'll notice that the hash distribution is not nearly as
    good as one might believe.  If one would have done:

        hash_long( inet_lnaof(item->m_addr.s_addr)),IP_HASHBITS)

    Then the hash_long function would have done a nice job.  Since
    one is not converting the network neutral IP address into a=20
    host binary format, here is an example of the hash distribution
    that, I believe via experimentation, is currently being seen on=20
    Little Endian 64 Bit systems....

------------------------------------------------
Testing byte 4 (least significant)
Input: 192.168.0.0 Hash-> 3e
Input: 192.168.0.1 Hash-> 3e
Input: 192.168.0.2 Hash-> 3e
Input: 192.168.0.3 Hash-> 3e
Input: 192.168.0.4 Hash-> 3e
Input: 192.168.0.5 Hash-> 3e
Input: 192.168.0.6 Hash-> 3e
Input: 192.168.0.7 Hash-> 3e
Input: 192.168.0.8 Hash-> 3e
Input: 192.168.0.9 Hash-> 3e
Input: 192.168.0.10 Hash-> 3e
Input: 192.168.0.11 Hash-> 3e
Input: 192.168.0.12 Hash-> 3e
Input: 192.168.0.13 Hash-> 3e
Input: 192.168.0.14 Hash-> 3e
Input: 192.168.0.15 Hash-> 3e
Input: 192.168.0.16 Hash-> 3e
Input: 192.168.0.17 Hash-> 3e
Input: 192.168.0.18 Hash-> 3e
Input: 192.168.0.19 Hash-> 3e
Input: 192.168.0.20 Hash-> 3e
Input: 192.168.0.21 Hash-> 3e
Input: 192.168.0.22 Hash-> 3e
Input: 192.168.0.23 Hash-> 3e
Input: 192.168.0.24 Hash-> 3e
Input: 192.168.0.25 Hash-> 3e
Input: 192.168.0.26 Hash-> 3e
Input: 192.168.0.27 Hash-> 3e
Input: 192.168.0.28 Hash-> 3e
Input: 192.168.0.29 Hash-> 3e
Input: 192.168.0.30 Hash-> 3e
Input: 192.168.0.31 Hash-> 3e
Input: 192.168.0.32 Hash-> 3e
Input: 192.168.0.33 Hash-> 3e
Input: 192.168.0.34 Hash-> 3e
Input: 192.168.0.35 Hash-> 3e
Input: 192.168.0.36 Hash-> 3e
Input: 192.168.0.37 Hash-> 3e
Input: 192.168.0.38 Hash-> 3e
Input: 192.168.0.39 Hash-> 3e
Input: 192.168.0.40 Hash-> 3e
Input: 192.168.0.41 Hash-> 3e
Input: 192.168.0.42 Hash-> 3e
Input: 192.168.0.43 Hash-> 3e
Input: 192.168.0.44 Hash-> 3e
Input: 192.168.0.45 Hash-> 3e
Input: 192.168.0.46 Hash-> 3e
Input: 192.168.0.47 Hash-> 3e
Input: 192.168.0.48 Hash-> 3e
Input: 192.168.0.49 Hash-> 3e
Input: 192.168.0.50 Hash-> 3e
Input: 192.168.0.51 Hash-> 3e
Input: 192.168.0.52 Hash-> 3e
Input: 192.168.0.53 Hash-> 3e
Input: 192.168.0.54 Hash-> 3e
Input: 192.168.0.55 Hash-> 3e
Input: 192.168.0.56 Hash-> 3e
Input: 192.168.0.57 Hash-> 3e
Input: 192.168.0.58 Hash-> 3e
Input: 192.168.0.59 Hash-> 3e
Input: 192.168.0.60 Hash-> 3e
Input: 192.168.0.61 Hash-> 3e
Input: 192.168.0.62 Hash-> 3e
Input: 192.168.0.63 Hash-> 3e
Input: 192.168.0.64 Hash-> 3e
Input: 192.168.0.65 Hash-> 3e
Input: 192.168.0.66 Hash-> 3e
Input: 192.168.0.67 Hash-> 3e
Input: 192.168.0.68 Hash-> 3e
Input: 192.168.0.69 Hash-> 3e
Input: 192.168.0.70 Hash-> 3e
Input: 192.168.0.71 Hash-> 3e
Input: 192.168.0.72 Hash-> 3e
Input: 192.168.0.73 Hash-> 3e
Input: 192.168.0.74 Hash-> 3e
Input: 192.168.0.75 Hash-> 3e
Input: 192.168.0.76 Hash-> 3e
Input: 192.168.0.77 Hash-> 3e
Input: 192.168.0.78 Hash-> 3e
Input: 192.168.0.79 Hash-> 3e
Input: 192.168.0.80 Hash-> 3e
Input: 192.168.0.81 Hash-> 3e
Input: 192.168.0.82 Hash-> 3e
Input: 192.168.0.83 Hash-> 3e
Input: 192.168.0.84 Hash-> 3e
Input: 192.168.0.85 Hash-> 3e
Input: 192.168.0.86 Hash-> 3e
Input: 192.168.0.87 Hash-> 3e
Input: 192.168.0.88 Hash-> 3e
Input: 192.168.0.89 Hash-> 3e
Input: 192.168.0.90 Hash-> 3e
Input: 192.168.0.91 Hash-> 3e
Input: 192.168.0.92 Hash-> 3e
Input: 192.168.0.93 Hash-> 3e
Input: 192.168.0.94 Hash-> 3e
Input: 192.168.0.95 Hash-> 3e
Input: 192.168.0.96 Hash-> 3e
Input: 192.168.0.97 Hash-> 3e
Input: 192.168.0.98 Hash-> 3e
Input: 192.168.0.99 Hash-> 3e
Input: 192.168.0.100 Hash-> 3e
Input: 192.168.0.101 Hash-> 3e
Input: 192.168.0.102 Hash-> 3e
Input: 192.168.0.103 Hash-> 3e
Input: 192.168.0.104 Hash-> 3e
Input: 192.168.0.105 Hash-> 3e
Input: 192.168.0.106 Hash-> 3e
Input: 192.168.0.107 Hash-> 3e
Input: 192.168.0.108 Hash-> 3e
Input: 192.168.0.109 Hash-> 3e
Input: 192.168.0.110 Hash-> 3e
Input: 192.168.0.111 Hash-> 3e
Input: 192.168.0.112 Hash-> 3e
Input: 192.168.0.113 Hash-> 3e
Input: 192.168.0.114 Hash-> 3e
Input: 192.168.0.115 Hash-> 3e
Input: 192.168.0.116 Hash-> 3e
Input: 192.168.0.117 Hash-> 3e
Input: 192.168.0.118 Hash-> 3e
Input: 192.168.0.119 Hash-> 3e
Input: 192.168.0.120 Hash-> 3e
Input: 192.168.0.121 Hash-> 3e
Input: 192.168.0.122 Hash-> 3e
Input: 192.168.0.123 Hash-> 3e
Input: 192.168.0.124 Hash-> 3e
Input: 192.168.0.125 Hash-> 3e
Input: 192.168.0.126 Hash-> 3e
Input: 192.168.0.127 Hash-> 3e
Input: 192.168.0.128 Hash-> 3d
Input: 192.168.0.129 Hash-> 3d
Input: 192.168.0.130 Hash-> 3d
Input: 192.168.0.131 Hash-> 3d
Input: 192.168.0.132 Hash-> 3d
Input: 192.168.0.133 Hash-> 3d
Input: 192.168.0.134 Hash-> 3d
Input: 192.168.0.135 Hash-> 3d
Input: 192.168.0.136 Hash-> 3d
Input: 192.168.0.137 Hash-> 3d
Input: 192.168.0.138 Hash-> 3d
Input: 192.168.0.139 Hash-> 3d
Input: 192.168.0.140 Hash-> 3d
Input: 192.168.0.141 Hash-> 3d
Input: 192.168.0.142 Hash-> 3d
Input: 192.168.0.143 Hash-> 3d
Input: 192.168.0.144 Hash-> 3d
Input: 192.168.0.145 Hash-> 3d
Input: 192.168.0.146 Hash-> 3d
Input: 192.168.0.147 Hash-> 3d
Input: 192.168.0.148 Hash-> 3d
Input: 192.168.0.149 Hash-> 3d
Input: 192.168.0.150 Hash-> 3d
Input: 192.168.0.151 Hash-> 3d
Input: 192.168.0.152 Hash-> 3d
Input: 192.168.0.153 Hash-> 3d
Input: 192.168.0.154 Hash-> 3d
Input: 192.168.0.155 Hash-> 3d
Input: 192.168.0.156 Hash-> 3d
Input: 192.168.0.157 Hash-> 3d
Input: 192.168.0.158 Hash-> 3d
Input: 192.168.0.159 Hash-> 3d
Input: 192.168.0.160 Hash-> 3d
Input: 192.168.0.161 Hash-> 3d
Input: 192.168.0.162 Hash-> 3d
Input: 192.168.0.163 Hash-> 3d
Input: 192.168.0.164 Hash-> 3d
Input: 192.168.0.165 Hash-> 3d
Input: 192.168.0.166 Hash-> 3d
Input: 192.168.0.167 Hash-> 3d
Input: 192.168.0.168 Hash-> 3d
Input: 192.168.0.169 Hash-> 3d
Input: 192.168.0.170 Hash-> 3d
Input: 192.168.0.171 Hash-> 3d
Input: 192.168.0.172 Hash-> 3d
Input: 192.168.0.173 Hash-> 3d
Input: 192.168.0.174 Hash-> 3d
Input: 192.168.0.175 Hash-> 3d
Input: 192.168.0.176 Hash-> 3d
Input: 192.168.0.177 Hash-> 3d
Input: 192.168.0.178 Hash-> 3d
Input: 192.168.0.179 Hash-> 3d
Input: 192.168.0.180 Hash-> 3d
Input: 192.168.0.181 Hash-> 3d
Input: 192.168.0.182 Hash-> 3d
Input: 192.168.0.183 Hash-> 3d
Input: 192.168.0.184 Hash-> 3d
Input: 192.168.0.185 Hash-> 3d
Input: 192.168.0.186 Hash-> 3d
Input: 192.168.0.187 Hash-> 3d
Input: 192.168.0.188 Hash-> 3d
Input: 192.168.0.189 Hash-> 3d
Input: 192.168.0.190 Hash-> 3d
Input: 192.168.0.191 Hash-> 3d
Input: 192.168.0.192 Hash-> 3d
Input: 192.168.0.193 Hash-> 3d
Input: 192.168.0.194 Hash-> 3d
Input: 192.168.0.195 Hash-> 3d
Input: 192.168.0.196 Hash-> 3d
Input: 192.168.0.197 Hash-> 3d
Input: 192.168.0.198 Hash-> 3d
Input: 192.168.0.199 Hash-> 3d
Input: 192.168.0.200 Hash-> 3d
Input: 192.168.0.201 Hash-> 3d
Input: 192.168.0.202 Hash-> 3d
Input: 192.168.0.203 Hash-> 3d
Input: 192.168.0.204 Hash-> 3d
Input: 192.168.0.205 Hash-> 3d
Input: 192.168.0.206 Hash-> 3d
Input: 192.168.0.207 Hash-> 3d
Input: 192.168.0.208 Hash-> 3d
Input: 192.168.0.209 Hash-> 3d
Input: 192.168.0.210 Hash-> 3d
Input: 192.168.0.211 Hash-> 3d
Input: 192.168.0.212 Hash-> 3d
Input: 192.168.0.213 Hash-> 3d
Input: 192.168.0.214 Hash-> 3d
Input: 192.168.0.215 Hash-> 3d
Input: 192.168.0.216 Hash-> 3d
Input: 192.168.0.217 Hash-> 3d
Input: 192.168.0.218 Hash-> 3d
Input: 192.168.0.219 Hash-> 3d
Input: 192.168.0.220 Hash-> 3d
Input: 192.168.0.221 Hash-> 3d
Input: 192.168.0.222 Hash-> 3d
Input: 192.168.0.223 Hash-> 3d
Input: 192.168.0.224 Hash-> 3d
Input: 192.168.0.225 Hash-> 3d
Input: 192.168.0.226 Hash-> 3d
Input: 192.168.0.227 Hash-> 3d
Input: 192.168.0.228 Hash-> 3d
Input: 192.168.0.229 Hash-> 3d
Input: 192.168.0.230 Hash-> 3d
Input: 192.168.0.231 Hash-> 3d
Input: 192.168.0.232 Hash-> 3d
Input: 192.168.0.233 Hash-> 3d
Input: 192.168.0.234 Hash-> 3d
Input: 192.168.0.235 Hash-> 3d
Input: 192.168.0.236 Hash-> 3d
Input: 192.168.0.237 Hash-> 3d
Input: 192.168.0.238 Hash-> 3d
Input: 192.168.0.239 Hash-> 3d
Input: 192.168.0.240 Hash-> 3d
Input: 192.168.0.241 Hash-> 3d
Input: 192.168.0.242 Hash-> 3d
Input: 192.168.0.243 Hash-> 3d
Input: 192.168.0.244 Hash-> 3d
Input: 192.168.0.245 Hash-> 3d
Input: 192.168.0.246 Hash-> 3d
Input: 192.168.0.247 Hash-> 3d
Input: 192.168.0.248 Hash-> 3d
Input: 192.168.0.249 Hash-> 3d
Input: 192.168.0.250 Hash-> 3d
Input: 192.168.0.251 Hash-> 3d
Input: 192.168.0.252 Hash-> 3d
Input: 192.168.0.253 Hash-> 3d
Input: 192.168.0.254 Hash-> 3d
Input: 192.168.0.255 Hash-> 3d
Testing byte 3=20
Input: 192.168.1.0 Hash-> 3e
Input: 192.168.1.1 Hash-> 3e
Input: 192.168.1.2 Hash-> 3e
Input: 192.168.1.3 Hash-> 3e
Input: 192.168.1.4 Hash-> 3e
Input: 192.168.1.5 Hash-> 3e
Input: 192.168.1.6 Hash-> 3e
Input: 192.168.1.7 Hash-> 3e
Input: 192.168.1.8 Hash-> 3e
Input: 192.168.1.9 Hash-> 3e
Input: 192.168.1.10 Hash-> 3e
Input: 192.168.1.11 Hash-> 3e
Input: 192.168.1.12 Hash-> 3e
Input: 192.168.1.13 Hash-> 3e
Input: 192.168.1.14 Hash-> 3e
Input: 192.168.1.15 Hash-> 3e
Input: 192.168.1.16 Hash-> 3e
Input: 192.168.1.17 Hash-> 3e
Input: 192.168.1.18 Hash-> 3e
Input: 192.168.1.19 Hash-> 3e
Input: 192.168.1.20 Hash-> 3e
Input: 192.168.1.21 Hash-> 3e
Input: 192.168.1.22 Hash-> 3e
Input: 192.168.1.23 Hash-> 3e
Input: 192.168.1.24 Hash-> 3e
Input: 192.168.1.25 Hash-> 3e
Input: 192.168.1.26 Hash-> 3e
Input: 192.168.1.27 Hash-> 3e
Input: 192.168.1.28 Hash-> 3e
Input: 192.168.1.29 Hash-> 3e
Input: 192.168.1.30 Hash-> 3e
Input: 192.168.1.31 Hash-> 3e
Input: 192.168.1.32 Hash-> 3e
Input: 192.168.1.33 Hash-> 3e
Input: 192.168.1.34 Hash-> 3e
Input: 192.168.1.35 Hash-> 3e
Input: 192.168.1.36 Hash-> 3e
Input: 192.168.1.37 Hash-> 3e
Input: 192.168.1.38 Hash-> 3e
Input: 192.168.1.39 Hash-> 3e
Input: 192.168.1.40 Hash-> 3e
Input: 192.168.1.41 Hash-> 3e
Input: 192.168.1.42 Hash-> 3e
Input: 192.168.1.43 Hash-> 3e
Input: 192.168.1.44 Hash-> 3e
Input: 192.168.1.45 Hash-> 3e
Input: 192.168.1.46 Hash-> 3e
Input: 192.168.1.47 Hash-> 3e
Input: 192.168.1.48 Hash-> 3e
Input: 192.168.1.49 Hash-> 3e
Input: 192.168.1.50 Hash-> 3e
Input: 192.168.1.51 Hash-> 3e
Input: 192.168.1.52 Hash-> 3e
Input: 192.168.1.53 Hash-> 3e
Input: 192.168.1.54 Hash-> 3e
Input: 192.168.1.55 Hash-> 3e
Input: 192.168.1.56 Hash-> 3e
Input: 192.168.1.57 Hash-> 3e
Input: 192.168.1.58 Hash-> 3e
Input: 192.168.1.59 Hash-> 3e
Input: 192.168.1.60 Hash-> 3e
Input: 192.168.1.61 Hash-> 3e
Input: 192.168.1.62 Hash-> 3e
Input: 192.168.1.63 Hash-> 3e
Input: 192.168.1.64 Hash-> 3e
Input: 192.168.1.65 Hash-> 3e
Input: 192.168.1.66 Hash-> 3e
Input: 192.168.1.67 Hash-> 3e
Input: 192.168.1.68 Hash-> 3e
Input: 192.168.1.69 Hash-> 3e
Input: 192.168.1.70 Hash-> 3e
Input: 192.168.1.71 Hash-> 3e
Input: 192.168.1.72 Hash-> 3e
Input: 192.168.1.73 Hash-> 3e
Input: 192.168.1.74 Hash-> 3e
Input: 192.168.1.75 Hash-> 3e
Input: 192.168.1.76 Hash-> 3e
Input: 192.168.1.77 Hash-> 3e
Input: 192.168.1.78 Hash-> 3e
Input: 192.168.1.79 Hash-> 3e
Input: 192.168.1.80 Hash-> 3e
Input: 192.168.1.81 Hash-> 3e
Input: 192.168.1.82 Hash-> 3e
Input: 192.168.1.83 Hash-> 3e
Input: 192.168.1.84 Hash-> 3e
Input: 192.168.1.85 Hash-> 3e
Input: 192.168.1.86 Hash-> 3e
Input: 192.168.1.87 Hash-> 3e
Input: 192.168.1.88 Hash-> 3e
Input: 192.168.1.89 Hash-> 3e
Input: 192.168.1.90 Hash-> 3e
Input: 192.168.1.91 Hash-> 3e
Input: 192.168.1.92 Hash-> 3e
Input: 192.168.1.93 Hash-> 3e
Input: 192.168.1.94 Hash-> 3e
Input: 192.168.1.95 Hash-> 3e
Input: 192.168.1.96 Hash-> 3e
Input: 192.168.1.97 Hash-> 3e
Input: 192.168.1.98 Hash-> 3e
Input: 192.168.1.99 Hash-> 3e
Input: 192.168.1.100 Hash-> 3e
Input: 192.168.1.101 Hash-> 3e
Input: 192.168.1.102 Hash-> 3e
Input: 192.168.1.103 Hash-> 3e
Input: 192.168.1.104 Hash-> 3e
Input: 192.168.1.105 Hash-> 3e
Input: 192.168.1.106 Hash-> 3e
Input: 192.168.1.107 Hash-> 3e
Input: 192.168.1.108 Hash-> 3e
Input: 192.168.1.109 Hash-> 3e
Input: 192.168.1.110 Hash-> 3e
Input: 192.168.1.111 Hash-> 3e
Input: 192.168.1.112 Hash-> 3e
Input: 192.168.1.113 Hash-> 3e
Input: 192.168.1.114 Hash-> 3e
Input: 192.168.1.115 Hash-> 3e
Input: 192.168.1.116 Hash-> 3e
Input: 192.168.1.117 Hash-> 3e
Input: 192.168.1.118 Hash-> 3e
Input: 192.168.1.119 Hash-> 3e
Input: 192.168.1.120 Hash-> 3e
Input: 192.168.1.121 Hash-> 3e
Input: 192.168.1.122 Hash-> 3e
Input: 192.168.1.123 Hash-> 3e
Input: 192.168.1.124 Hash-> 3e
Input: 192.168.1.125 Hash-> 3e
Input: 192.168.1.126 Hash-> 3e
Input: 192.168.1.127 Hash-> 3e
Input: 192.168.1.128 Hash-> 3d
Input: 192.168.1.129 Hash-> 3d
Input: 192.168.1.130 Hash-> 3d
Input: 192.168.1.131 Hash-> 3d
Input: 192.168.1.132 Hash-> 3d
Input: 192.168.1.133 Hash-> 3d
Input: 192.168.1.134 Hash-> 3d
Input: 192.168.1.135 Hash-> 3d
Input: 192.168.1.136 Hash-> 3d
Input: 192.168.1.137 Hash-> 3d
Input: 192.168.1.138 Hash-> 3d
Input: 192.168.1.139 Hash-> 3d
Input: 192.168.1.140 Hash-> 3d
Input: 192.168.1.141 Hash-> 3d
Input: 192.168.1.142 Hash-> 3d
Input: 192.168.1.143 Hash-> 3d
Input: 192.168.1.144 Hash-> 3d
Input: 192.168.1.145 Hash-> 3d
Input: 192.168.1.146 Hash-> 3d
Input: 192.168.1.147 Hash-> 3d
Input: 192.168.1.148 Hash-> 3d
Input: 192.168.1.149 Hash-> 3d
Input: 192.168.1.150 Hash-> 3d
Input: 192.168.1.151 Hash-> 3d
Input: 192.168.1.152 Hash-> 3d
Input: 192.168.1.153 Hash-> 3d
Input: 192.168.1.154 Hash-> 3d
Input: 192.168.1.155 Hash-> 3d
Input: 192.168.1.156 Hash-> 3d
Input: 192.168.1.157 Hash-> 3d
Input: 192.168.1.158 Hash-> 3d
Input: 192.168.1.159 Hash-> 3d
Input: 192.168.1.160 Hash-> 3d
Input: 192.168.1.161 Hash-> 3d
Input: 192.168.1.162 Hash-> 3d
Input: 192.168.1.163 Hash-> 3d
Input: 192.168.1.164 Hash-> 3d
Input: 192.168.1.165 Hash-> 3d
Input: 192.168.1.166 Hash-> 3d
Input: 192.168.1.167 Hash-> 3d
Input: 192.168.1.168 Hash-> 3d
Input: 192.168.1.169 Hash-> 3d
Input: 192.168.1.170 Hash-> 3d
Input: 192.168.1.171 Hash-> 3d
Input: 192.168.1.172 Hash-> 3d
Input: 192.168.1.173 Hash-> 3d
Input: 192.168.1.174 Hash-> 3d
Input: 192.168.1.175 Hash-> 3d
Input: 192.168.1.176 Hash-> 3d
Input: 192.168.1.177 Hash-> 3d
Input: 192.168.1.178 Hash-> 3d
Input: 192.168.1.179 Hash-> 3d
Input: 192.168.1.180 Hash-> 3d
Input: 192.168.1.181 Hash-> 3d
Input: 192.168.1.182 Hash-> 3d
Input: 192.168.1.183 Hash-> 3d
Input: 192.168.1.184 Hash-> 3d
Input: 192.168.1.185 Hash-> 3d
Input: 192.168.1.186 Hash-> 3d
Input: 192.168.1.187 Hash-> 3d
Input: 192.168.1.188 Hash-> 3d
Input: 192.168.1.189 Hash-> 3d
Input: 192.168.1.190 Hash-> 3d
Input: 192.168.1.191 Hash-> 3d
Input: 192.168.1.192 Hash-> 3d
Input: 192.168.1.193 Hash-> 3d
Input: 192.168.1.194 Hash-> 3d
Input: 192.168.1.195 Hash-> 3d
Input: 192.168.1.196 Hash-> 3d
Input: 192.168.1.197 Hash-> 3d
Input: 192.168.1.198 Hash-> 3d
Input: 192.168.1.199 Hash-> 3d
Input: 192.168.1.200 Hash-> 3d
Input: 192.168.1.201 Hash-> 3d
Input: 192.168.1.202 Hash-> 3d
Input: 192.168.1.203 Hash-> 3d
Input: 192.168.1.204 Hash-> 3d
Input: 192.168.1.205 Hash-> 3d
Input: 192.168.1.206 Hash-> 3d
Input: 192.168.1.207 Hash-> 3d
Input: 192.168.1.208 Hash-> 3d
Input: 192.168.1.209 Hash-> 3d
Input: 192.168.1.210 Hash-> 3d
Input: 192.168.1.211 Hash-> 3d
Input: 192.168.1.212 Hash-> 3d
Input: 192.168.1.213 Hash-> 3d
Input: 192.168.1.214 Hash-> 3d
Input: 192.168.1.215 Hash-> 3d
Input: 192.168.1.216 Hash-> 3d
Input: 192.168.1.217 Hash-> 3d
Input: 192.168.1.218 Hash-> 3d
Input: 192.168.1.219 Hash-> 3d
Input: 192.168.1.220 Hash-> 3d
Input: 192.168.1.221 Hash-> 3d
Input: 192.168.1.222 Hash-> 3d
Input: 192.168.1.223 Hash-> 3d
Input: 192.168.1.224 Hash-> 3d
Input: 192.168.1.225 Hash-> 3d
Input: 192.168.1.226 Hash-> 3d
Input: 192.168.1.227 Hash-> 3d
Input: 192.168.1.228 Hash-> 3d
Input: 192.168.1.229 Hash-> 3d
Input: 192.168.1.230 Hash-> 3d
Input: 192.168.1.231 Hash-> 3d
Input: 192.168.1.232 Hash-> 3d
Input: 192.168.1.233 Hash-> 3d
Input: 192.168.1.234 Hash-> 3d
Input: 192.168.1.235 Hash-> 3d
Input: 192.168.1.236 Hash-> 3d
Input: 192.168.1.237 Hash-> 3d
Input: 192.168.1.238 Hash-> 3d
Input: 192.168.1.239 Hash-> 3d
Input: 192.168.1.240 Hash-> 3d
Input: 192.168.1.241 Hash-> 3d
Input: 192.168.1.242 Hash-> 3d
Input: 192.168.1.243 Hash-> 3d
Input: 192.168.1.244 Hash-> 3d
Input: 192.168.1.245 Hash-> 3d
Input: 192.168.1.246 Hash-> 3d
Input: 192.168.1.247 Hash-> 3d
Input: 192.168.1.248 Hash-> 3d
Input: 192.168.1.249 Hash-> 3d
Input: 192.168.1.250 Hash-> 3d
Input: 192.168.1.251 Hash-> 3d
Input: 192.168.1.252 Hash-> 3d
Input: 192.168.1.253 Hash-> 3d
Input: 192.168.1.254 Hash-> 3d
Input: 192.168.1.255 Hash-> 3d
Testing byte 2=20
Input: 192.169.0.0 Hash-> f6
Input: 192.169.0.1 Hash-> f6
Input: 192.169.0.2 Hash-> f6
Input: 192.169.0.3 Hash-> f6
Input: 192.169.0.4 Hash-> f6
Input: 192.169.0.5 Hash-> f6
Input: 192.169.0.6 Hash-> f6
Input: 192.169.0.7 Hash-> f6
Input: 192.169.0.8 Hash-> f6
Input: 192.169.0.9 Hash-> f6
Input: 192.169.0.10 Hash-> f6
Input: 192.169.0.11 Hash-> f6
Input: 192.169.0.12 Hash-> f6
Input: 192.169.0.13 Hash-> f6
Input: 192.169.0.14 Hash-> f6
Input: 192.169.0.15 Hash-> f6
Input: 192.169.0.16 Hash-> f6
Input: 192.169.0.17 Hash-> f6
Input: 192.169.0.18 Hash-> f6
Input: 192.169.0.19 Hash-> f6
Input: 192.169.0.20 Hash-> f6
Input: 192.169.0.21 Hash-> f6
Input: 192.169.0.22 Hash-> f6
Input: 192.169.0.23 Hash-> f6
Input: 192.169.0.24 Hash-> f6
Input: 192.169.0.25 Hash-> f6
Input: 192.169.0.26 Hash-> f6
Input: 192.169.0.27 Hash-> f6
Input: 192.169.0.28 Hash-> f6
Input: 192.169.0.29 Hash-> f6
Input: 192.169.0.30 Hash-> f6
Input: 192.169.0.31 Hash-> f6
Input: 192.169.0.32 Hash-> f6
Input: 192.169.0.33 Hash-> f6
Input: 192.169.0.34 Hash-> f6
Input: 192.169.0.35 Hash-> f6
Input: 192.169.0.36 Hash-> f6
Input: 192.169.0.37 Hash-> f6
Input: 192.169.0.38 Hash-> f6
Input: 192.169.0.39 Hash-> f6
Input: 192.169.0.40 Hash-> f6
Input: 192.169.0.41 Hash-> f6
Input: 192.169.0.42 Hash-> f6
Input: 192.169.0.43 Hash-> f6
Input: 192.169.0.44 Hash-> f6
Input: 192.169.0.45 Hash-> f6
Input: 192.169.0.46 Hash-> f6
Input: 192.169.0.47 Hash-> f6
Input: 192.169.0.48 Hash-> f6
Input: 192.169.0.49 Hash-> f6
Input: 192.169.0.50 Hash-> f6
Input: 192.169.0.51 Hash-> f6
Input: 192.169.0.52 Hash-> f6
Input: 192.169.0.53 Hash-> f6
Input: 192.169.0.54 Hash-> f6
Input: 192.169.0.55 Hash-> f6
Input: 192.169.0.56 Hash-> f6
Input: 192.169.0.57 Hash-> f6
Input: 192.169.0.58 Hash-> f6
Input: 192.169.0.59 Hash-> f6
Input: 192.169.0.60 Hash-> f6
Input: 192.169.0.61 Hash-> f6
Input: 192.169.0.62 Hash-> f6
Input: 192.169.0.63 Hash-> f6
Input: 192.169.0.64 Hash-> f6
Input: 192.169.0.65 Hash-> f6
Input: 192.169.0.66 Hash-> f6
Input: 192.169.0.67 Hash-> f6
Input: 192.169.0.68 Hash-> f6
Input: 192.169.0.69 Hash-> f6
Input: 192.169.0.70 Hash-> f6
Input: 192.169.0.71 Hash-> f6
Input: 192.169.0.72 Hash-> f6
Input: 192.169.0.73 Hash-> f6
Input: 192.169.0.74 Hash-> f6
Input: 192.169.0.75 Hash-> f6
Input: 192.169.0.76 Hash-> f6
Input: 192.169.0.77 Hash-> f6
Input: 192.169.0.78 Hash-> f6
Input: 192.169.0.79 Hash-> f6
Input: 192.169.0.80 Hash-> f6
Input: 192.169.0.81 Hash-> f6
Input: 192.169.0.82 Hash-> f6
Input: 192.169.0.83 Hash-> f6
Input: 192.169.0.84 Hash-> f6
Input: 192.169.0.85 Hash-> f6
Input: 192.169.0.86 Hash-> f6
Input: 192.169.0.87 Hash-> f6
Input: 192.169.0.88 Hash-> f6
Input: 192.169.0.89 Hash-> f6
Input: 192.169.0.90 Hash-> f6
Input: 192.169.0.91 Hash-> f6
Input: 192.169.0.92 Hash-> f6
Input: 192.169.0.93 Hash-> f6
Input: 192.169.0.94 Hash-> f6
Input: 192.169.0.95 Hash-> f6
Input: 192.169.0.96 Hash-> f6
Input: 192.169.0.97 Hash-> f6
Input: 192.169.0.98 Hash-> f6
Input: 192.169.0.99 Hash-> f6
Input: 192.169.0.100 Hash-> f6
Input: 192.169.0.101 Hash-> f6
Input: 192.169.0.102 Hash-> f6
Input: 192.169.0.103 Hash-> f6
Input: 192.169.0.104 Hash-> f6
Input: 192.169.0.105 Hash-> f6
Input: 192.169.0.106 Hash-> f6
Input: 192.169.0.107 Hash-> f6
Input: 192.169.0.108 Hash-> f6
Input: 192.169.0.109 Hash-> f6
Input: 192.169.0.110 Hash-> f6
Input: 192.169.0.111 Hash-> f6
Input: 192.169.0.112 Hash-> f6
Input: 192.169.0.113 Hash-> f6
Input: 192.169.0.114 Hash-> f6
Input: 192.169.0.115 Hash-> f6
Input: 192.169.0.116 Hash-> f6
Input: 192.169.0.117 Hash-> f6
Input: 192.169.0.118 Hash-> f6
Input: 192.169.0.119 Hash-> f6
Input: 192.169.0.120 Hash-> f6
Input: 192.169.0.121 Hash-> f6
Input: 192.169.0.122 Hash-> f6
Input: 192.169.0.123 Hash-> f6
Input: 192.169.0.124 Hash-> f6
Input: 192.169.0.125 Hash-> f6
Input: 192.169.0.126 Hash-> f6
Input: 192.169.0.127 Hash-> f6
Input: 192.169.0.128 Hash-> f5
Input: 192.169.0.129 Hash-> f5
Input: 192.169.0.130 Hash-> f5
Input: 192.169.0.131 Hash-> f5
Input: 192.169.0.132 Hash-> f5
Input: 192.169.0.133 Hash-> f5
Input: 192.169.0.134 Hash-> f5
Input: 192.169.0.135 Hash-> f5
Input: 192.169.0.136 Hash-> f5
Input: 192.169.0.137 Hash-> f5
Input: 192.169.0.138 Hash-> f5
Input: 192.169.0.139 Hash-> f5
Input: 192.169.0.140 Hash-> f5
Input: 192.169.0.141 Hash-> f5
Input: 192.169.0.142 Hash-> f5
Input: 192.169.0.143 Hash-> f5
Input: 192.169.0.144 Hash-> f5
Input: 192.169.0.145 Hash-> f5
Input: 192.169.0.146 Hash-> f5
Input: 192.169.0.147 Hash-> f5
Input: 192.169.0.148 Hash-> f5
Input: 192.169.0.149 Hash-> f5
Input: 192.169.0.150 Hash-> f5
Input: 192.169.0.151 Hash-> f5
Input: 192.169.0.152 Hash-> f5
Input: 192.169.0.153 Hash-> f5
Input: 192.169.0.154 Hash-> f5
Input: 192.169.0.155 Hash-> f5
Input: 192.169.0.156 Hash-> f5
Input: 192.169.0.157 Hash-> f5
Input: 192.169.0.158 Hash-> f5
Input: 192.169.0.159 Hash-> f5
Input: 192.169.0.160 Hash-> f5
Input: 192.169.0.161 Hash-> f5
Input: 192.169.0.162 Hash-> f5
Input: 192.169.0.163 Hash-> f5
Input: 192.169.0.164 Hash-> f5
Input: 192.169.0.165 Hash-> f5
Input: 192.169.0.166 Hash-> f5
Input: 192.169.0.167 Hash-> f5
Input: 192.169.0.168 Hash-> f5
Input: 192.169.0.169 Hash-> f5
Input: 192.169.0.170 Hash-> f5
Input: 192.169.0.171 Hash-> f5
Input: 192.169.0.172 Hash-> f5
Input: 192.169.0.173 Hash-> f5
Input: 192.169.0.174 Hash-> f5
Input: 192.169.0.175 Hash-> f5
Input: 192.169.0.176 Hash-> f5
Input: 192.169.0.177 Hash-> f5
Input: 192.169.0.178 Hash-> f5
Input: 192.169.0.179 Hash-> f5
Input: 192.169.0.180 Hash-> f5
Input: 192.169.0.181 Hash-> f5
Input: 192.169.0.182 Hash-> f5
Input: 192.169.0.183 Hash-> f5
Input: 192.169.0.184 Hash-> f5
Input: 192.169.0.185 Hash-> f5
Input: 192.169.0.186 Hash-> f5
Input: 192.169.0.187 Hash-> f5
Input: 192.169.0.188 Hash-> f5
Input: 192.169.0.189 Hash-> f5
Input: 192.169.0.190 Hash-> f5
Input: 192.169.0.191 Hash-> f5
Input: 192.169.0.192 Hash-> f5
Input: 192.169.0.193 Hash-> f5
Input: 192.169.0.194 Hash-> f5
Input: 192.169.0.195 Hash-> f5
Input: 192.169.0.196 Hash-> f5
Input: 192.169.0.197 Hash-> f5
Input: 192.169.0.198 Hash-> f5
Input: 192.169.0.199 Hash-> f5
Input: 192.169.0.200 Hash-> f5
Input: 192.169.0.201 Hash-> f5
Input: 192.169.0.202 Hash-> f5
Input: 192.169.0.203 Hash-> f5
Input: 192.169.0.204 Hash-> f5
Input: 192.169.0.205 Hash-> f5
Input: 192.169.0.206 Hash-> f5
Input: 192.169.0.207 Hash-> f5
Input: 192.169.0.208 Hash-> f5
Input: 192.169.0.209 Hash-> f5
Input: 192.169.0.210 Hash-> f5
Input: 192.169.0.211 Hash-> f5
Input: 192.169.0.212 Hash-> f5
Input: 192.169.0.213 Hash-> f5
Input: 192.169.0.214 Hash-> f5
Input: 192.169.0.215 Hash-> f5
Input: 192.169.0.216 Hash-> f5
Input: 192.169.0.217 Hash-> f5
Input: 192.169.0.218 Hash-> f5
Input: 192.169.0.219 Hash-> f5
Input: 192.169.0.220 Hash-> f5
Input: 192.169.0.221 Hash-> f5
Input: 192.169.0.222 Hash-> f5
Input: 192.169.0.223 Hash-> f5
Input: 192.169.0.224 Hash-> f5
Input: 192.169.0.225 Hash-> f5
Input: 192.169.0.226 Hash-> f5
Input: 192.169.0.227 Hash-> f5
Input: 192.169.0.228 Hash-> f5
Input: 192.169.0.229 Hash-> f5
Input: 192.169.0.230 Hash-> f5
Input: 192.169.0.231 Hash-> f5
Input: 192.169.0.232 Hash-> f5
Input: 192.169.0.233 Hash-> f5
Input: 192.169.0.234 Hash-> f5
Input: 192.169.0.235 Hash-> f5
Input: 192.169.0.236 Hash-> f5
Input: 192.169.0.237 Hash-> f5
Input: 192.169.0.238 Hash-> f5
Input: 192.169.0.239 Hash-> f5
Input: 192.169.0.240 Hash-> f5
Input: 192.169.0.241 Hash-> f5
Input: 192.169.0.242 Hash-> f5
Input: 192.169.0.243 Hash-> f5
Input: 192.169.0.244 Hash-> f5
Input: 192.169.0.245 Hash-> f5
Input: 192.169.0.246 Hash-> f5
Input: 192.169.0.247 Hash-> f5
Input: 192.169.0.248 Hash-> f5
Input: 192.169.0.249 Hash-> f5
Input: 192.169.0.250 Hash-> f5
Input: 192.169.0.251 Hash-> f5
Input: 192.169.0.252 Hash-> f5
Input: 192.169.0.253 Hash-> f5
Input: 192.169.0.254 Hash-> f5
Input: 192.169.0.255 Hash-> f5
Testing byte 1 (Most significant byte)
Input: 193.169.2.0 Hash-> 17
Input: 193.169.2.1 Hash-> 17
Input: 193.169.2.2 Hash-> 17
Input: 193.169.2.3 Hash-> 17
Input: 193.169.2.4 Hash-> 17
Input: 193.169.2.5 Hash-> 17
Input: 193.169.2.6 Hash-> 17
Input: 193.169.2.7 Hash-> 17
Input: 193.169.2.8 Hash-> 17
Input: 193.169.2.9 Hash-> 17
Input: 193.169.2.10 Hash-> 17
Input: 193.169.2.11 Hash-> 17
Input: 193.169.2.12 Hash-> 17
Input: 193.169.2.13 Hash-> 17
Input: 193.169.2.14 Hash-> 17
Input: 193.169.2.15 Hash-> 17
Input: 193.169.2.16 Hash-> 17
Input: 193.169.2.17 Hash-> 17
Input: 193.169.2.18 Hash-> 17
Input: 193.169.2.19 Hash-> 17
Input: 193.169.2.20 Hash-> 17
Input: 193.169.2.21 Hash-> 17
Input: 193.169.2.22 Hash-> 17
Input: 193.169.2.23 Hash-> 17
Input: 193.169.2.24 Hash-> 17
Input: 193.169.2.25 Hash-> 17
Input: 193.169.2.26 Hash-> 17
Input: 193.169.2.27 Hash-> 17
Input: 193.169.2.28 Hash-> 17
Input: 193.169.2.29 Hash-> 17
Input: 193.169.2.30 Hash-> 17
Input: 193.169.2.31 Hash-> 17
Input: 193.169.2.32 Hash-> 17
Input: 193.169.2.33 Hash-> 17
Input: 193.169.2.34 Hash-> 17
Input: 193.169.2.35 Hash-> 17
Input: 193.169.2.36 Hash-> 17
Input: 193.169.2.37 Hash-> 17
Input: 193.169.2.38 Hash-> 17
Input: 193.169.2.39 Hash-> 17
Input: 193.169.2.40 Hash-> 17
Input: 193.169.2.41 Hash-> 17
Input: 193.169.2.42 Hash-> 17
Input: 193.169.2.43 Hash-> 17
Input: 193.169.2.44 Hash-> 17
Input: 193.169.2.45 Hash-> 17
Input: 193.169.2.46 Hash-> 17
Input: 193.169.2.47 Hash-> 17
Input: 193.169.2.48 Hash-> 17
Input: 193.169.2.49 Hash-> 17
Input: 193.169.2.50 Hash-> 17
Input: 193.169.2.51 Hash-> 17
Input: 193.169.2.52 Hash-> 17
Input: 193.169.2.53 Hash-> 17
Input: 193.169.2.54 Hash-> 17
Input: 193.169.2.55 Hash-> 17
Input: 193.169.2.56 Hash-> 17
Input: 193.169.2.57 Hash-> 17
Input: 193.169.2.58 Hash-> 17
Input: 193.169.2.59 Hash-> 17
Input: 193.169.2.60 Hash-> 17
Input: 193.169.2.61 Hash-> 17
Input: 193.169.2.62 Hash-> 17
Input: 193.169.2.63 Hash-> 17
Input: 193.169.2.64 Hash-> 17
Input: 193.169.2.65 Hash-> 17
Input: 193.169.2.66 Hash-> 17
Input: 193.169.2.67 Hash-> 17
Input: 193.169.2.68 Hash-> 17
Input: 193.169.2.69 Hash-> 17
Input: 193.169.2.70 Hash-> 17
Input: 193.169.2.71 Hash-> 17
Input: 193.169.2.72 Hash-> 17
Input: 193.169.2.73 Hash-> 17
Input: 193.169.2.74 Hash-> 17
Input: 193.169.2.75 Hash-> 17
Input: 193.169.2.76 Hash-> 17
Input: 193.169.2.77 Hash-> 17
Input: 193.169.2.78 Hash-> 17
Input: 193.169.2.79 Hash-> 17
Input: 193.169.2.80 Hash-> 17
Input: 193.169.2.81 Hash-> 17
Input: 193.169.2.82 Hash-> 17
Input: 193.169.2.83 Hash-> 17
Input: 193.169.2.84 Hash-> 17
Input: 193.169.2.85 Hash-> 17
Input: 193.169.2.86 Hash-> 17
Input: 193.169.2.87 Hash-> 17
Input: 193.169.2.88 Hash-> 17
Input: 193.169.2.89 Hash-> 17
Input: 193.169.2.90 Hash-> 17
Input: 193.169.2.91 Hash-> 17
Input: 193.169.2.92 Hash-> 17
Input: 193.169.2.93 Hash-> 17
Input: 193.169.2.94 Hash-> 17
Input: 193.169.2.95 Hash-> 17
Input: 193.169.2.96 Hash-> 17
Input: 193.169.2.97 Hash-> 17
Input: 193.169.2.98 Hash-> 17
Input: 193.169.2.99 Hash-> 17
Input: 193.169.2.100 Hash-> 17
Input: 193.169.2.101 Hash-> 17
Input: 193.169.2.102 Hash-> 17
Input: 193.169.2.103 Hash-> 17
Input: 193.169.2.104 Hash-> 17
Input: 193.169.2.105 Hash-> 17
Input: 193.169.2.106 Hash-> 17
Input: 193.169.2.107 Hash-> 17
Input: 193.169.2.108 Hash-> 17
Input: 193.169.2.109 Hash-> 17
Input: 193.169.2.110 Hash-> 17
Input: 193.169.2.111 Hash-> 17
Input: 193.169.2.112 Hash-> 17
Input: 193.169.2.113 Hash-> 17
Input: 193.169.2.114 Hash-> 17
Input: 193.169.2.115 Hash-> 17
Input: 193.169.2.116 Hash-> 17
Input: 193.169.2.117 Hash-> 17
Input: 193.169.2.118 Hash-> 17
Input: 193.169.2.119 Hash-> 17
Input: 193.169.2.120 Hash-> 17
Input: 193.169.2.121 Hash-> 17
Input: 193.169.2.122 Hash-> 17
Input: 193.169.2.123 Hash-> 17
Input: 193.169.2.124 Hash-> 17
Input: 193.169.2.125 Hash-> 17
Input: 193.169.2.126 Hash-> 17
Input: 193.169.2.127 Hash-> 17
Input: 193.169.2.128 Hash-> 17
Input: 193.169.2.129 Hash-> 17
Input: 193.169.2.130 Hash-> 17
Input: 193.169.2.131 Hash-> 17
Input: 193.169.2.132 Hash-> 17
Input: 193.169.2.133 Hash-> 17
Input: 193.169.2.134 Hash-> 17
Input: 193.169.2.135 Hash-> 17
Input: 193.169.2.136 Hash-> 17
Input: 193.169.2.137 Hash-> 17
Input: 193.169.2.138 Hash-> 17
Input: 193.169.2.139 Hash-> 17
Input: 193.169.2.140 Hash-> 17
Input: 193.169.2.141 Hash-> 17
Input: 193.169.2.142 Hash-> 17
Input: 193.169.2.143 Hash-> 17
Input: 193.169.2.144 Hash-> 17
Input: 193.169.2.145 Hash-> 17
Input: 193.169.2.146 Hash-> 17
Input: 193.169.2.147 Hash-> 17
Input: 193.169.2.148 Hash-> 17
Input: 193.169.2.149 Hash-> 17
Input: 193.169.2.150 Hash-> 17
Input: 193.169.2.151 Hash-> 17
Input: 193.169.2.152 Hash-> 17
Input: 193.169.2.153 Hash-> 17
Input: 193.169.2.154 Hash-> 17
Input: 193.169.2.155 Hash-> 17
Input: 193.169.2.156 Hash-> 17
Input: 193.169.2.157 Hash-> 17
Input: 193.169.2.158 Hash-> 17
Input: 193.169.2.159 Hash-> 17
Input: 193.169.2.160 Hash-> 17
Input: 193.169.2.161 Hash-> 17
Input: 193.169.2.162 Hash-> 17
Input: 193.169.2.163 Hash-> 17
Input: 193.169.2.164 Hash-> 17
Input: 193.169.2.165 Hash-> 17
Input: 193.169.2.166 Hash-> 17
Input: 193.169.2.167 Hash-> 17
Input: 193.169.2.168 Hash-> 17
Input: 193.169.2.169 Hash-> 17
Input: 193.169.2.170 Hash-> 17
Input: 193.169.2.171 Hash-> 17
Input: 193.169.2.172 Hash-> 17
Input: 193.169.2.173 Hash-> 17
Input: 193.169.2.174 Hash-> 17
Input: 193.169.2.175 Hash-> 17
Input: 193.169.2.176 Hash-> 17
Input: 193.169.2.177 Hash-> 17
Input: 193.169.2.178 Hash-> 17
Input: 193.169.2.179 Hash-> 17
Input: 193.169.2.180 Hash-> 17
Input: 193.169.2.181 Hash-> 17
Input: 193.169.2.182 Hash-> 17
Input: 193.169.2.183 Hash-> 17
Input: 193.169.2.184 Hash-> 17
Input: 193.169.2.185 Hash-> 17
Input: 193.169.2.186 Hash-> 17
Input: 193.169.2.187 Hash-> 17
Input: 193.169.2.188 Hash-> 17
Input: 193.169.2.189 Hash-> 17
Input: 193.169.2.190 Hash-> 17
Input: 193.169.2.191 Hash-> 17
Input: 193.169.2.192 Hash-> 17
Input: 193.169.2.193 Hash-> 17
Input: 193.169.2.194 Hash-> 17
Input: 193.169.2.195 Hash-> 17
Input: 193.169.2.196 Hash-> 17
Input: 193.169.2.197 Hash-> 17
Input: 193.169.2.198 Hash-> 17
Input: 193.169.2.199 Hash-> 17
Input: 193.169.2.200 Hash-> 17
Input: 193.169.2.201 Hash-> 17
Input: 193.169.2.202 Hash-> 17
Input: 193.169.2.203 Hash-> 17
Input: 193.169.2.204 Hash-> 17
Input: 193.169.2.205 Hash-> 17
Input: 193.169.2.206 Hash-> 17
Input: 193.169.2.207 Hash-> 17
Input: 193.169.2.208 Hash-> 17
Input: 193.169.2.209 Hash-> 17
Input: 193.169.2.210 Hash-> 17
Input: 193.169.2.211 Hash-> 17
Input: 193.169.2.212 Hash-> 17
Input: 193.169.2.213 Hash-> 17
Input: 193.169.2.214 Hash-> 17
Input: 193.169.2.215 Hash-> 17
Input: 193.169.2.216 Hash-> 17
Input: 193.169.2.217 Hash-> 17
Input: 193.169.2.218 Hash-> 17
Input: 193.169.2.219 Hash-> 17
Input: 193.169.2.220 Hash-> 17
Input: 193.169.2.221 Hash-> 17
Input: 193.169.2.222 Hash-> 17
Input: 193.169.2.223 Hash-> 17
Input: 193.169.2.224 Hash-> 17
Input: 193.169.2.225 Hash-> 17
Input: 193.169.2.226 Hash-> 17
Input: 193.169.2.227 Hash-> 17
Input: 193.169.2.228 Hash-> 17
Input: 193.169.2.229 Hash-> 17
Input: 193.169.2.230 Hash-> 17
Input: 193.169.2.231 Hash-> 17
Input: 193.169.2.232 Hash-> 17
Input: 193.169.2.233 Hash-> 17
Input: 193.169.2.234 Hash-> 17
Input: 193.169.2.235 Hash-> 17
Input: 193.169.2.236 Hash-> 17
Input: 193.169.2.237 Hash-> 17
Input: 193.169.2.238 Hash-> 17
Input: 193.169.2.239 Hash-> 17
Input: 193.169.2.240 Hash-> 17
Input: 193.169.2.241 Hash-> 17
Input: 193.169.2.242 Hash-> 17
Input: 193.169.2.243 Hash-> 17
Input: 193.169.2.244 Hash-> 17
Input: 193.169.2.245 Hash-> 17
Input: 193.169.2.246 Hash-> 17
Input: 193.169.2.247 Hash-> 17
Input: 193.169.2.248 Hash-> 17
Input: 193.169.2.249 Hash-> 17
Input: 193.169.2.250 Hash-> 17
Input: 193.169.2.251 Hash-> 17
Input: 193.169.2.252 Hash-> 17
Input: 193.169.2.253 Hash-> 17
Input: 193.169.2.254 Hash-> 17
Input: 193.169.2.255 Hash-> 17
------------

---------

    Now you say "Ok that's not too cool, but why is this really =
important ?"

        Well, it turns out that the RedHat EL 4 release has some issues
    with the locking around the buckets that this hash is being
    used to index into, and with the distribution being so not... it
    leads to a lock race, followed by a kernel dereference of null,
    followed shortly by angry phone calls.... True, the race needs
    to be fixed, but it sure would be nice if the pressure were a=20
    tad lower on the lock. It would greatly reduce the probability
    of the panic, and also improve the performance (scaling) of
    the system, if a few more buckets were used :-)

    I've talked this over with Charles, and Bruce, and they pointed
    me in your direction ...=20
   =20
    How would you prefer to proceed ?

        A. It's your code, and you would prefer to tinker without
            some bozo adding his two bits.

        B. You're way too busy to go after this, and would=20
            welcome a diff -u patch.

        C. You'll scratch your head, think about it, and get back
            after morning coffee :-)

        D. It will only take a few seconds to add the=20
                inet_lnaof( ) to the offending lines, and it will be
                done before you can say Jack Flash :-)
   =20
        E. Go away, you're bothering me :-)

Enjoy,
Don Capps
capps_at_iozone_dot_org





------=_NextPart_000_00B6_01C600A9.12598ED0
Content-Type: text/html;
	charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<HTML><HEAD>
<META http-equiv=3DContent-Type content=3D"text/html; =
charset=3Diso-8859-1">
<META content=3D"MSHTML 6.00.2900.2769" name=3DGENERATOR>
<STYLE></STYLE>
</HEAD>
<BODY bgColor=3D#ffffff>
<DIV><FONT face=3DArial size=3D2>Neil,</FONT></DIV>
<DIV><FONT face=3DArial size=3D2></FONT>&nbsp;</DIV>
<DIV><FONT face=3DArial size=3D2>&nbsp;&nbsp;&nbsp; I think I have =
discovered an=20
interesting performance anomaly.</FONT></DIV>
<DIV><FONT face=3DArial size=3D2></FONT>&nbsp;</DIV>
<DIV><FONT face=3DArial size=3D2>&nbsp;&nbsp;&nbsp; In the svcauth code =
there are=20
places that do:</FONT></DIV>
<DIV><FONT face=3DArial size=3D2></FONT>&nbsp;</DIV>
<DIV><FONT face=3DArial size=3D2>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=20
hash_long((unsigned long)item-&gt;m_addr.s_addr, =
IP_HASHBITS);</FONT></DIV>
<DIV><FONT face=3DArial size=3D2></FONT>&nbsp;</DIV>
<DIV><FONT face=3DArial size=3D2>&nbsp;&nbsp;&nbsp; Ok... That seems =
reasonable, but=20
then again...maybe not....</FONT></DIV>
<DIV><FONT face=3DArial size=3D2></FONT>&nbsp;</DIV>
<DIV><FONT face=3DArial size=3D2>&nbsp;&nbsp;&nbsp; I believe that =
s_addr is an IP=20
address in Network Neutral format. </FONT></DIV>
<DIV><FONT face=3DArial size=3D2>&nbsp;&nbsp;&nbsp;&nbsp; (Big =
Endian)</FONT></DIV>
<DIV><FONT face=3DArial size=3D2></FONT>&nbsp;</DIV>
<DIV><FONT face=3DArial size=3D2>&nbsp;&nbsp;&nbsp; So... When one is on =
a Little=20
Endian system, the hash_long</FONT></DIV>
<DIV><FONT face=3DArial size=3D2>&nbsp;&nbsp;&nbsp; function gets handed =
a Big=20
Endian value as a long, and</FONT></DIV>
<DIV><FONT face=3DArial size=3D2>&nbsp;&nbsp;&nbsp; later, via the magic =
of being a=20
Little Endian system,</FONT></DIV>
<DIV><FONT face=3DArial size=3D2>&nbsp;&nbsp;&nbsp; gets byte =
swapped.</FONT></DIV>
<DIV><FONT face=3DArial size=3D2></FONT>&nbsp;</DIV>
<DIV><FONT face=3DArial size=3D2>&nbsp;&nbsp;&nbsp; Step =
1.&nbsp;192.168.1.2 becomes=20
2.1.168.192 (byte swap)</FONT></DIV>
<DIV><FONT face=3DArial size=3D2></FONT>&nbsp;</DIV>
<DIV><FONT face=3DArial size=3D2>&nbsp;&nbsp;&nbsp; Step 2.&nbsp; The 32 =
bit IP=20
address becomes a 64 bit long when</FONT></DIV>
<DIV><FONT face=3DArial size=3D2>&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp;=20
&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp;&nbsp; this code is compiled and =
run on an=20
Opteron, or</FONT></DIV>
<DIV><FONT face=3DArial size=3D2>&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp;=20
&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp;&nbsp; an IA-64 =
system.</FONT></DIV>
<DIV><FONT face=3DArial size=3D2>&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp;=20
&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp;&nbsp; 2.1.168.192 -&gt;=20
0.0.0.0.2.1.168.192</FONT></DIV>
<DIV><FONT face=3DArial size=3D2>&nbsp;&nbsp;&nbsp; Step 3. Call the =
hash_long() and=20
get back a hash value</FONT></DIV>
<DIV><FONT face=3DArial size=3D2>&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp;=20
&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; that is IP_HASHBITS (8) in=20
size.</FONT></DIV>
<DIV><FONT face=3DArial size=3D2></FONT>&nbsp;</DIV>
<DIV><FONT face=3DArial size=3D2>&nbsp;&nbsp;&nbsp; You'll notice that =
the hash=20
distribution is not nearly as</FONT></DIV>
<DIV><FONT face=3DArial size=3D2>&nbsp;&nbsp;&nbsp; good as one might =
believe.&nbsp;=20
If one would have done:</FONT></DIV>
<DIV><FONT face=3DArial size=3D2></FONT>&nbsp;</DIV>
<DIV><FONT face=3DArial size=3D2>&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; =
hash_long(=20
inet_lnaof(item-&gt;m_addr.s_addr)),IP_HASHBITS)</FONT></DIV>
<DIV><FONT face=3DArial size=3D2></FONT>&nbsp;</DIV>
<DIV><FONT face=3DArial size=3D2>&nbsp;&nbsp;&nbsp; Then the hash_long =
function=20
would have done a nice job.&nbsp; Since</FONT></DIV>
<DIV><FONT face=3DArial size=3D2>&nbsp;&nbsp;&nbsp; one is not =
converting the=20
network neutral IP address into a </FONT></DIV>
<DIV><FONT face=3DArial size=3D2>&nbsp;&nbsp;&nbsp; host binary format, =
here is an=20
example of the hash distribution</FONT></DIV>
<DIV><FONT face=3DArial size=3D2>&nbsp;&nbsp;&nbsp; that, I believe via=20
experimentation, is&nbsp;currently being seen on </FONT></DIV>
<DIV><FONT face=3DArial size=3D2>&nbsp;&nbsp;&nbsp; Little Endian 64 Bit =

systems....</FONT></DIV>
<DIV><FONT face=3DArial size=3D2></FONT>&nbsp;</DIV>
<DIV><FONT face=3DArial=20
size=3D2>------------------------------------------------</FONT></DIV>
<DIV><FONT face=3DArial size=3D2>Testing byte 4 (least =
significant)<BR>Input:=20
192.168.0.0 Hash-&gt; 3e<BR>Input: 192.168.0.1 Hash-&gt; 3e<BR>Input:=20
192.168.0.2 Hash-&gt; 3e<BR>Input: 192.168.0.3 Hash-&gt; 3e<BR>Input:=20
192.168.0.4 Hash-&gt; 3e<BR>Input: 192.168.0.5 Hash-&gt; 3e<BR>Input:=20
192.168.0.6 Hash-&gt; 3e<BR>Input: 192.168.0.7 Hash-&gt; 3e<BR>Input:=20
192.168.0.8 Hash-&gt; 3e<BR>Input: 192.168.0.9 Hash-&gt; 3e<BR>Input:=20
192.168.0.10 Hash-&gt; 3e<BR>Input: 192.168.0.11 Hash-&gt; 3e<BR>Input:=20
192.168.0.12 Hash-&gt; 3e<BR>Input: 192.168.0.13 Hash-&gt; 3e<BR>Input:=20
192.168.0.14 Hash-&gt; 3e<BR>Input: 192.168.0.15 Hash-&gt; 3e<BR>Input:=20
192.168.0.16 Hash-&gt; 3e<BR>Input: 192.168.0.17 Hash-&gt; 3e<BR>Input:=20
192.168.0.18 Hash-&gt; 3e<BR>Input: 192.168.0.19 Hash-&gt; 3e<BR>Input:=20
192.168.0.20 Hash-&gt; 3e<BR>Input: 192.168.0.21 Hash-&gt; 3e<BR>Input:=20
192.168.0.22 Hash-&gt; 3e<BR>Input: 192.168.0.23 Hash-&gt; 3e<BR>Input:=20
192.168.0.24 Hash-&gt; 3e<BR>Input: 192.168.0.25 Hash-&gt; 3e<BR>Input:=20
192.168.0.26 Hash-&gt; 3e<BR>Input: 192.168.0.27 Hash-&gt; 3e<BR>Input:=20
192.168.0.28 Hash-&gt; 3e<BR>Input: 192.168.0.29 Hash-&gt; 3e<BR>Input:=20
192.168.0.30 Hash-&gt; 3e<BR>Input: 192.168.0.31 Hash-&gt; 3e<BR>Input:=20
192.168.0.32 Hash-&gt; 3e<BR>Input: 192.168.0.33 Hash-&gt; 3e<BR>Input:=20
192.168.0.34 Hash-&gt; 3e<BR>Input: 192.168.0.35 Hash-&gt; 3e<BR>Input:=20
192.168.0.36 Hash-&gt; 3e<BR>Input: 192.168.0.37 Hash-&gt; 3e<BR>Input:=20
192.168.0.38 Hash-&gt; 3e<BR>Input: 192.168.0.39 Hash-&gt; 3e<BR>Input:=20
192.168.0.40 Hash-&gt; 3e<BR>Input: 192.168.0.41 Hash-&gt; 3e<BR>Input:=20
192.168.0.42 Hash-&gt; 3e<BR>Input: 192.168.0.43 Hash-&gt; 3e<BR>Input:=20
192.168.0.44 Hash-&gt; 3e<BR>Input: 192.168.0.45 Hash-&gt; 3e<BR>Input:=20
192.168.0.46 Hash-&gt; 3e<BR>Input: 192.168.0.47 Hash-&gt; 3e<BR>Input:=20
192.168.0.48 Hash-&gt; 3e<BR>Input: 192.168.0.49 Hash-&gt; 3e<BR>Input:=20
192.168.0.50 Hash-&gt; 3e<BR>Input: 192.168.0.51 Hash-&gt; 3e<BR>Input:=20
192.168.0.52 Hash-&gt; 3e<BR>Input: 192.168.0.53 Hash-&gt; 3e<BR>Input:=20
192.168.0.54 Hash-&gt; 3e<BR>Input: 192.168.0.55 Hash-&gt; 3e<BR>Input:=20
192.168.0.56 Hash-&gt; 3e<BR>Input: 192.168.0.57 Hash-&gt; 3e<BR>Input:=20
192.168.0.58 Hash-&gt; 3e<BR>Input: 192.168.0.59 Hash-&gt; 3e<BR>Input:=20
192.168.0.60 Hash-&gt; 3e<BR>Input: 192.168.0.61 Hash-&gt; 3e<BR>Input:=20
192.168.0.62 Hash-&gt; 3e<BR>Input: 192.168.0.63 Hash-&gt; 3e<BR>Input:=20
192.168.0.64 Hash-&gt; 3e<BR>Input: 192.168.0.65 Hash-&gt; 3e<BR>Input:=20
192.168.0.66 Hash-&gt; 3e<BR>Input: 192.168.0.67 Hash-&gt; 3e<BR>Input:=20
192.168.0.68 Hash-&gt; 3e<BR>Input: 192.168.0.69 Hash-&gt; 3e<BR>Input:=20
192.168.0.70 Hash-&gt; 3e<BR>Input: 192.168.0.71 Hash-&gt; 3e<BR>Input:=20
192.168.0.72 Hash-&gt; 3e<BR>Input: 192.168.0.73 Hash-&gt; 3e<BR>Input:=20
192.168.0.74 Hash-&gt; 3e<BR>Input: 192.168.0.75 Hash-&gt; 3e<BR>Input:=20
192.168.0.76 Hash-&gt; 3e<BR>Input: 192.168.0.77 Hash-&gt; 3e<BR>Input:=20
192.168.0.78 Hash-&gt; 3e<BR>Input: 192.168.0.79 Hash-&gt; 3e<BR>Input:=20
192.168.0.80 Hash-&gt; 3e<BR>Input: 192.168.0.81 Hash-&gt; 3e<BR>Input:=20
192.168.0.82 Hash-&gt; 3e<BR>Input: 192.168.0.83 Hash-&gt; 3e<BR>Input:=20
192.168.0.84 Hash-&gt; 3e<BR>Input: 192.168.0.85 Hash-&gt; 3e<BR>Input:=20
192.168.0.86 Hash-&gt; 3e<BR>Input: 192.168.0.87 Hash-&gt; 3e<BR>Input:=20
192.168.0.88 Hash-&gt; 3e<BR>Input: 192.168.0.89 Hash-&gt; 3e<BR>Input:=20
192.168.0.90 Hash-&gt; 3e<BR>Input: 192.168.0.91 Hash-&gt; 3e<BR>Input:=20
192.168.0.92 Hash-&gt; 3e<BR>Input: 192.168.0.93 Hash-&gt; 3e<BR>Input:=20
192.168.0.94 Hash-&gt; 3e<BR>Input: 192.168.0.95 Hash-&gt; 3e<BR>Input:=20
192.168.0.96 Hash-&gt; 3e<BR>Input: 192.168.0.97 Hash-&gt; 3e<BR>Input:=20
192.168.0.98 Hash-&gt; 3e<BR>Input: 192.168.0.99 Hash-&gt; 3e<BR>Input:=20
192.168.0.100 Hash-&gt; 3e<BR>Input: 192.168.0.101 Hash-&gt; =
3e<BR>Input:=20
192.168.0.102 Hash-&gt; 3e<BR>Input: 192.168.0.103 Hash-&gt; =
3e<BR>Input:=20
192.168.0.104 Hash-&gt; 3e<BR>Input: 192.168.0.105 Hash-&gt; =
3e<BR>Input:=20
192.168.0.106 Hash-&gt; 3e<BR>Input: 192.168.0.107 Hash-&gt; =
3e<BR>Input:=20
192.168.0.108 Hash-&gt; 3e<BR>Input: 192.168.0.109 Hash-&gt; =
3e<BR>Input:=20
192.168.0.110 Hash-&gt; 3e<BR>Input: 192.168.0.111 Hash-&gt; =
3e<BR>Input:=20
192.168.0.112 Hash-&gt; 3e<BR>Input: 192.168.0.113 Hash-&gt; =
3e<BR>Input:=20
192.168.0.114 Hash-&gt; 3e<BR>Input: 192.168.0.115 Hash-&gt; =
3e<BR>Input:=20
192.168.0.116 Hash-&gt; 3e<BR>Input: 192.168.0.117 Hash-&gt; =
3e<BR>Input:=20
192.168.0.118 Hash-&gt; 3e<BR>Input: 192.168.0.119 Hash-&gt; =
3e<BR>Input:=20
192.168.0.120 Hash-&gt; 3e<BR>Input: 192.168.0.121 Hash-&gt; =
3e<BR>Input:=20
192.168.0.122 Hash-&gt; 3e<BR>Input: 192.168.0.123 Hash-&gt; =
3e<BR>Input:=20
192.168.0.124 Hash-&gt; 3e<BR>Input: 192.168.0.125 Hash-&gt; =
3e<BR>Input:=20
192.168.0.126 Hash-&gt; 3e<BR>Input: 192.168.0.127 Hash-&gt; =
3e<BR>Input:=20
192.168.0.128 Hash-&gt; 3d<BR>Input: 192.168.0.129 Hash-&gt; =
3d<BR>Input:=20
192.168.0.130 Hash-&gt; 3d<BR>Input: 192.168.0.131 Hash-&gt; =
3d<BR>Input:=20
192.168.0.132 Hash-&gt; 3d<BR>Input: 192.168.0.133 Hash-&gt; =
3d<BR>Input:=20
192.168.0.134 Hash-&gt; 3d<BR>Input: 192.168.0.135 Hash-&gt; =
3d<BR>Input:=20
192.168.0.136 Hash-&gt; 3d<BR>Input: 192.168.0.137 Hash-&gt; =
3d<BR>Input:=20
192.168.0.138 Hash-&gt; 3d<BR>Input: 192.168.0.139 Hash-&gt; =
3d<BR>Input:=20
192.168.0.140 Hash-&gt; 3d<BR>Input: 192.168.0.141 Hash-&gt; =
3d<BR>Input:=20
192.168.0.142 Hash-&gt; 3d<BR>Input: 192.168.0.143 Hash-&gt; =
3d<BR>Input:=20
192.168.0.144 Hash-&gt; 3d<BR>Input: 192.168.0.145 Hash-&gt; =
3d<BR>Input:=20
192.168.0.146 Hash-&gt; 3d<BR>Input: 192.168.0.147 Hash-&gt; =
3d<BR>Input:=20
192.168.0.148 Hash-&gt; 3d<BR>Input: 192.168.0.149 Hash-&gt; =
3d<BR>Input:=20
192.168.0.150 Hash-&gt; 3d<BR>Input: 192.168.0.151 Hash-&gt; =
3d<BR>Input:=20
192.168.0.152 Hash-&gt; 3d<BR>Input: 192.168.0.153 Hash-&gt; =
3d<BR>Input:=20
192.168.0.154 Hash-&gt; 3d<BR>Input: 192.168.0.155 Hash-&gt; =
3d<BR>Input:=20
192.168.0.156 Hash-&gt; 3d<BR>Input: 192.168.0.157 Hash-&gt; =
3d<BR>Input:=20
192.168.0.158 Hash-&gt; 3d<BR>Input: 192.168.0.159 Hash-&gt; =
3d<BR>Input:=20
192.168.0.160 Hash-&gt; 3d<BR>Input: 192.168.0.161 Hash-&gt; =
3d<BR>Input:=20
192.168.0.162 Hash-&gt; 3d<BR>Input: 192.168.0.163 Hash-&gt; =
3d<BR>Input:=20
192.168.0.164 Hash-&gt; 3d<BR>Input: 192.168.0.165 Hash-&gt; =
3d<BR>Input:=20
192.168.0.166 Hash-&gt; 3d<BR>Input: 192.168.0.167 Hash-&gt; =
3d<BR>Input:=20
192.168.0.168 Hash-&gt; 3d<BR>Input: 192.168.0.169 Hash-&gt; =
3d<BR>Input:=20
192.168.0.170 Hash-&gt; 3d<BR>Input: 192.168.0.171 Hash-&gt; =
3d<BR>Input:=20
192.168.0.172 Hash-&gt; 3d<BR>Input: 192.168.0.173 Hash-&gt; =
3d<BR>Input:=20
192.168.0.174 Hash-&gt; 3d<BR>Input: 192.168.0.175 Hash-&gt; =
3d<BR>Input:=20
192.168.0.176 Hash-&gt; 3d<BR>Input: 192.168.0.177 Hash-&gt; =
3d<BR>Input:=20
192.168.0.178 Hash-&gt; 3d<BR>Input: 192.168.0.179 Hash-&gt; =
3d<BR>Input:=20
192.168.0.180 Hash-&gt; 3d<BR>Input: 192.168.0.181 Hash-&gt; =
3d<BR>Input:=20
192.168.0.182 Hash-&gt; 3d<BR>Input: 192.168.0.183 Hash-&gt; =
3d<BR>Input:=20
192.168.0.184 Hash-&gt; 3d<BR>Input: 192.168.0.185 Hash-&gt; =
3d<BR>Input:=20
192.168.0.186 Hash-&gt; 3d<BR>Input: 192.168.0.187 Hash-&gt; =
3d<BR>Input:=20
192.168.0.188 Hash-&gt; 3d<BR>Input: 192.168.0.189 Hash-&gt; =
3d<BR>Input:=20
192.168.0.190 Hash-&gt; 3d<BR>Input: 192.168.0.191 Hash-&gt; =
3d<BR>Input:=20
192.168.0.192 Hash-&gt; 3d<BR>Input: 192.168.0.193 Hash-&gt; =
3d<BR>Input:=20
192.168.0.194 Hash-&gt; 3d<BR>Input: 192.168.0.195 Hash-&gt; =
3d<BR>Input:=20
192.168.0.196 Hash-&gt; 3d<BR>Input: 192.168.0.197 Hash-&gt; =
3d<BR>Input:=20
192.168.0.198 Hash-&gt; 3d<BR>Input: 192.168.0.199 Hash-&gt; =
3d<BR>Input:=20
192.168.0.200 Hash-&gt; 3d<BR>Input: 192.168.0.201 Hash-&gt; =
3d<BR>Input:=20
192.168.0.202 Hash-&gt; 3d<BR>Input: 192.168.0.203 Hash-&gt; =
3d<BR>Input:=20
192.168.0.204 Hash-&gt; 3d<BR>Input: 192.168.0.205 Hash-&gt; =
3d<BR>Input:=20
192.168.0.206 Hash-&gt; 3d<BR>Input: 192.168.0.207 Hash-&gt; =
3d<BR>Input:=20
192.168.0.208 Hash-&gt; 3d<BR>Input: 192.168.0.209 Hash-&gt; =
3d<BR>Input:=20
192.168.0.210 Hash-&gt; 3d<BR>Input: 192.168.0.211 Hash-&gt; =
3d<BR>Input:=20
192.168.0.212 Hash-&gt; 3d<BR>Input: 192.168.0.213 Hash-&gt; =
3d<BR>Input:=20
192.168.0.214 Hash-&gt; 3d<BR>Input: 192.168.0.215 Hash-&gt; =
3d<BR>Input:=20
192.168.0.216 Hash-&gt; 3d<BR>Input: 192.168.0.217 Hash-&gt; =
3d<BR>Input:=20
192.168.0.218 Hash-&gt; 3d<BR>Input: 192.168.0.219 Hash-&gt; =
3d<BR>Input:=20
192.168.0.220 Hash-&gt; 3d<BR>Input: 192.168.0.221 Hash-&gt; =
3d<BR>Input:=20
192.168.0.222 Hash-&gt; 3d<BR>Input: 192.168.0.223 Hash-&gt; =
3d<BR>Input:=20
192.168.0.224 Hash-&gt; 3d<BR>Input: 192.168.0.225 Hash-&gt; =
3d<BR>Input:=20
192.168.0.226 Hash-&gt; 3d<BR>Input: 192.168.0.227 Hash-&gt; =
3d<BR>Input:=20
192.168.0.228 Hash-&gt; 3d<BR>Input: 192.168.0.229 Hash-&gt; =
3d<BR>Input:=20
192.168.0.230 Hash-&gt; 3d<BR>Input: 192.168.0.231 Hash-&gt; =
3d<BR>Input:=20
192.168.0.232 Hash-&gt; 3d<BR>Input: 192.168.0.233 Hash-&gt; =
3d<BR>Input:=20
192.168.0.234 Hash-&gt; 3d<BR>Input: 192.168.0.235 Hash-&gt; =
3d<BR>Input:=20
192.168.0.236 Hash-&gt; 3d<BR>Input: 192.168.0.237 Hash-&gt; =
3d<BR>Input:=20
192.168.0.238 Hash-&gt; 3d<BR>Input: 192.168.0.239 Hash-&gt; =
3d<BR>Input:=20
192.168.0.240 Hash-&gt; 3d<BR>Input: 192.168.0.241 Hash-&gt; =
3d<BR>Input:=20
192.168.0.242 Hash-&gt; 3d<BR>Input: 192.168.0.243 Hash-&gt; =
3d<BR>Input:=20
192.168.0.244 Hash-&gt; 3d<BR>Input: 192.168.0.245 Hash-&gt; =
3d<BR>Input:=20
192.168.0.246 Hash-&gt; 3d<BR>Input: 192.168.0.247 Hash-&gt; =
3d<BR>Input:=20
192.168.0.248 Hash-&gt; 3d<BR>Input: 192.168.0.249 Hash-&gt; =
3d<BR>Input:=20
192.168.0.250 Hash-&gt; 3d<BR>Input: 192.168.0.251 Hash-&gt; =
3d<BR>Input:=20
192.168.0.252 Hash-&gt; 3d<BR>Input: 192.168.0.253 Hash-&gt; =
3d<BR>Input:=20
192.168.0.254 Hash-&gt; 3d<BR>Input: 192.168.0.255 Hash-&gt; =
3d<BR>Testing byte=20
3 <BR>Input: 192.168.1.0 Hash-&gt; 3e<BR>Input: 192.168.1.1 Hash-&gt;=20
3e<BR>Input: 192.168.1.2 Hash-&gt; 3e<BR>Input: 192.168.1.3 Hash-&gt;=20
3e<BR>Input: 192.168.1.4 Hash-&gt; 3e<BR>Input: 192.168.1.5 Hash-&gt;=20
3e<BR>Input: 192.168.1.6 Hash-&gt; 3e<BR>Input: 192.168.1.7 Hash-&gt;=20
3e<BR>Input: 192.168.1.8 Hash-&gt; 3e<BR>Input: 192.168.1.9 Hash-&gt;=20
3e<BR>Input: 192.168.1.10 Hash-&gt; 3e<BR>Input: 192.168.1.11 Hash-&gt;=20
3e<BR>Input: 192.168.1.12 Hash-&gt; 3e<BR>Input: 192.168.1.13 Hash-&gt;=20
3e<BR>Input: 192.168.1.14 Hash-&gt; 3e<BR>Input: 192.168.1.15 Hash-&gt;=20
3e<BR>Input: 192.168.1.16 Hash-&gt; 3e<BR>Input: 192.168.1.17 Hash-&gt;=20
3e<BR>Input: 192.168.1.18 Hash-&gt; 3e<BR>Input: 192.168.1.19 Hash-&gt;=20
3e<BR>Input: 192.168.1.20 Hash-&gt; 3e<BR>Input: 192.168.1.21 Hash-&gt;=20
3e<BR>Input: 192.168.1.22 Hash-&gt; 3e<BR>Input: 192.168.1.23 Hash-&gt;=20
3e<BR>Input: 192.168.1.24 Hash-&gt; 3e<BR>Input: 192.168.1.25 Hash-&gt;=20
3e<BR>Input: 192.168.1.26 Hash-&gt; 3e<BR>Input: 192.168.1.27 Hash-&gt;=20
3e<BR>Input: 192.168.1.28 Hash-&gt; 3e<BR>Input: 192.168.1.29 Hash-&gt;=20
3e<BR>Input: 192.168.1.30 Hash-&gt; 3e<BR>Input: 192.168.1.31 Hash-&gt;=20
3e<BR>Input: 192.168.1.32 Hash-&gt; 3e<BR>Input: 192.168.1.33 Hash-&gt;=20
3e<BR>Input: 192.168.1.34 Hash-&gt; 3e<BR>Input: 192.168.1.35 Hash-&gt;=20
3e<BR>Input: 192.168.1.36 Hash-&gt; 3e<BR>Input: 192.168.1.37 Hash-&gt;=20
3e<BR>Input: 192.168.1.38 Hash-&gt; 3e<BR>Input: 192.168.1.39 Hash-&gt;=20
3e<BR>Input: 192.168.1.40 Hash-&gt; 3e<BR>Input: 192.168.1.41 Hash-&gt;=20
3e<BR>Input: 192.168.1.42 Hash-&gt; 3e<BR>Input: 192.168.1.43 Hash-&gt;=20
3e<BR>Input: 192.168.1.44 Hash-&gt; 3e<BR>Input: 192.168.1.45 Hash-&gt;=20
3e<BR>Input: 192.168.1.46 Hash-&gt; 3e<BR>Input: 192.168.1.47 Hash-&gt;=20
3e<BR>Input: 192.168.1.48 Hash-&gt; 3e<BR>Input: 192.168.1.49 Hash-&gt;=20
3e<BR>Input: 192.168.1.50 Hash-&gt; 3e<BR>Input: 192.168.1.51 Hash-&gt;=20
3e<BR>Input: 192.168.1.52 Hash-&gt; 3e<BR>Input: 192.168.1.53 Hash-&gt;=20
3e<BR>Input: 192.168.1.54 Hash-&gt; 3e<BR>Input: 192.168.1.55 Hash-&gt;=20
3e<BR>Input: 192.168.1.56 Hash-&gt; 3e<BR>Input: 192.168.1.57 Hash-&gt;=20
3e<BR>Input: 192.168.1.58 Hash-&gt; 3e<BR>Input: 192.168.1.59 Hash-&gt;=20
3e<BR>Input: 192.168.1.60 Hash-&gt; 3e<BR>Input: 192.168.1.61 Hash-&gt;=20
3e<BR>Input: 192.168.1.62 Hash-&gt; 3e<BR>Input: 192.168.1.63 Hash-&gt;=20
3e<BR>Input: 192.168.1.64 Hash-&gt; 3e<BR>Input: 192.168.1.65 Hash-&gt;=20
3e<BR>Input: 192.168.1.66 Hash-&gt; 3e<BR>Input: 192.168.1.67 Hash-&gt;=20
3e<BR>Input: 192.168.1.68 Hash-&gt; 3e<BR>Input: 192.168.1.69 Hash-&gt;=20
3e<BR>Input: 192.168.1.70 Hash-&gt; 3e<BR>Input: 192.168.1.71 Hash-&gt;=20
3e<BR>Input: 192.168.1.72 Hash-&gt; 3e<BR>Input: 192.168.1.73 Hash-&gt;=20
3e<BR>Input: 192.168.1.74 Hash-&gt; 3e<BR>Input: 192.168.1.75 Hash-&gt;=20
3e<BR>Input: 192.168.1.76 Hash-&gt; 3e<BR>Input: 192.168.1.77 Hash-&gt;=20
3e<BR>Input: 192.168.1.78 Hash-&gt; 3e<BR>Input: 192.168.1.79 Hash-&gt;=20
3e<BR>Input: 192.168.1.80 Hash-&gt; 3e<BR>Input: 192.168.1.81 Hash-&gt;=20
3e<BR>Input: 192.168.1.82 Hash-&gt; 3e<BR>Input: 192.168.1.83 Hash-&gt;=20
3e<BR>Input: 192.168.1.84 Hash-&gt; 3e<BR>Input: 192.168.1.85 Hash-&gt;=20
3e<BR>Input: 192.168.1.86 Hash-&gt; 3e<BR>Input: 192.168.1.87 Hash-&gt;=20
3e<BR>Input: 192.168.1.88 Hash-&gt; 3e<BR>Input: 192.168.1.89 Hash-&gt;=20
3e<BR>Input: 192.168.1.90 Hash-&gt; 3e<BR>Input: 192.168.1.91 Hash-&gt;=20
3e<BR>Input: 192.168.1.92 Hash-&gt; 3e<BR>Input: 192.168.1.93 Hash-&gt;=20
3e<BR>Input: 192.168.1.94 Hash-&gt; 3e<BR>Input: 192.168.1.95 Hash-&gt;=20
3e<BR>Input: 192.168.1.96 Hash-&gt; 3e<BR>Input: 192.168.1.97 Hash-&gt;=20
3e<BR>Input: 192.168.1.98 Hash-&gt; 3e<BR>Input: 192.168.1.99 Hash-&gt;=20
3e<BR>Input: 192.168.1.100 Hash-&gt; 3e<BR>Input: 192.168.1.101 =
Hash-&gt;=20
3e<BR>Input: 192.168.1.102 Hash-&gt; 3e<BR>Input: 192.168.1.103 =
Hash-&gt;=20
3e<BR>Input: 192.168.1.104 Hash-&gt; 3e<BR>Input: 192.168.1.105 =
Hash-&gt;=20
3e<BR>Input: 192.168.1.106 Hash-&gt; 3e<BR>Input: 192.168.1.107 =
Hash-&gt;=20
3e<BR>Input: 192.168.1.108 Hash-&gt; 3e<BR>Input: 192.168.1.109 =
Hash-&gt;=20
3e<BR>Input: 192.168.1.110 Hash-&gt; 3e<BR>Input: 192.168.1.111 =
Hash-&gt;=20
3e<BR>Input: 192.168.1.112 Hash-&gt; 3e<BR>Input: 192.168.1.113 =
Hash-&gt;=20
3e<BR>Input: 192.168.1.114 Hash-&gt; 3e<BR>Input: 192.168.1.115 =
Hash-&gt;=20
3e<BR>Input: 192.168.1.116 Hash-&gt; 3e<BR>Input: 192.168.1.117 =
Hash-&gt;=20
3e<BR>Input: 192.168.1.118 Hash-&gt; 3e<BR>Input: 192.168.1.119 =
Hash-&gt;=20
3e<BR>Input: 192.168.1.120 Hash-&gt; 3e<BR>Input: 192.168.1.121 =
Hash-&gt;=20
3e<BR>Input: 192.168.1.122 Hash-&gt; 3e<BR>Input: 192.168.1.123 =
Hash-&gt;=20
3e<BR>Input: 192.168.1.124 Hash-&gt; 3e<BR>Input: 192.168.1.125 =
Hash-&gt;=20
3e<BR>Input: 192.168.1.126 Hash-&gt; 3e<BR>Input: 192.168.1.127 =
Hash-&gt;=20
3e<BR>Input: 192.168.1.128 Hash-&gt; 3d<BR>Input: 192.168.1.129 =
Hash-&gt;=20
3d<BR>Input: 192.168.1.130 Hash-&gt; 3d<BR>Input: 192.168.1.131 =
Hash-&gt;=20
3d<BR>Input: 192.168.1.132 Hash-&gt; 3d<BR>Input: 192.168.1.133 =
Hash-&gt;=20
3d<BR>Input: 192.168.1.134 Hash-&gt; 3d<BR>Input: 192.168.1.135 =
Hash-&gt;=20
3d<BR>Input: 192.168.1.136 Hash-&gt; 3d<BR>Input: 192.168.1.137 =
Hash-&gt;=20
3d<BR>Input: 192.168.1.138 Hash-&gt; 3d<BR>Input: 192.168.1.139 =
Hash-&gt;=20
3d<BR>Input: 192.168.1.140 Hash-&gt; 3d<BR>Input: 192.168.1.141 =
Hash-&gt;=20
3d<BR>Input: 192.168.1.142 Hash-&gt; 3d<BR>Input: 192.168.1.143 =
Hash-&gt;=20
3d<BR>Input: 192.168.1.144 Hash-&gt; 3d<BR>Input: 192.168.1.145 =
Hash-&gt;=20
3d<BR>Input: 192.168.1.146 Hash-&gt; 3d<BR>Input: 192.168.1.147 =
Hash-&gt;=20
3d<BR>Input: 192.168.1.148 Hash-&gt; 3d<BR>Input: 192.168.1.149 =
Hash-&gt;=20
3d<BR>Input: 192.168.1.150 Hash-&gt; 3d<BR>Input: 192.168.1.151 =
Hash-&gt;=20
3d<BR>Input: 192.168.1.152 Hash-&gt; 3d<BR>Input: 192.168.1.153 =
Hash-&gt;=20
3d<BR>Input: 192.168.1.154 Hash-&gt; 3d<BR>Input: 192.168.1.155 =
Hash-&gt;=20
3d<BR>Input: 192.168.1.156 Hash-&gt; 3d<BR>Input: 192.168.1.157 =
Hash-&gt;=20
3d<BR>Input: 192.168.1.158 Hash-&gt; 3d<BR>Input: 192.168.1.159 =
Hash-&gt;=20
3d<BR>Input: 192.168.1.160 Hash-&gt; 3d<BR>Input: 192.168.1.161 =
Hash-&gt;=20
3d<BR>Input: 192.168.1.162 Hash-&gt; 3d<BR>Input: 192.168.1.163 =
Hash-&gt;=20
3d<BR>Input: 192.168.1.164 Hash-&gt; 3d<BR>Input: 192.168.1.165 =
Hash-&gt;=20
3d<BR>Input: 192.168.1.166 Hash-&gt; 3d<BR>Input: 192.168.1.167 =
Hash-&gt;=20
3d<BR>Input: 192.168.1.168 Hash-&gt; 3d<BR>Input: 192.168.1.169 =
Hash-&gt;=20
3d<BR>Input: 192.168.1.170 Hash-&gt; 3d<BR>Input: 192.168.1.171 =
Hash-&gt;=20
3d<BR>Input: 192.168.1.172 Hash-&gt; 3d<BR>Input: 192.168.1.173 =
Hash-&gt;=20
3d<BR>Input: 192.168.1.174 Hash-&gt; 3d<BR>Input: 192.168.1.175 =
Hash-&gt;=20
3d<BR>Input: 192.168.1.176 Hash-&gt; 3d<BR>Input: 192.168.1.177 =
Hash-&gt;=20
3d<BR>Input: 192.168.1.178 Hash-&gt; 3d<BR>Input: 192.168.1.179 =
Hash-&gt;=20
3d<BR>Input: 192.168.1.180 Hash-&gt; 3d<BR>Input: 192.168.1.181 =
Hash-&gt;=20
3d<BR>Input: 192.168.1.182 Hash-&gt; 3d<BR>Input: 192.168.1.183 =
Hash-&gt;=20
3d<BR>Input: 192.168.1.184 Hash-&gt; 3d<BR>Input: 192.168.1.185 =
Hash-&gt;=20
3d<BR>Input: 192.168.1.186 Hash-&gt; 3d<BR>Input: 192.168.1.187 =
Hash-&gt;=20
3d<BR>Input: 192.168.1.188 Hash-&gt; 3d<BR>Input: 192.168.1.189 =
Hash-&gt;=20
3d<BR>Input: 192.168.1.190 Hash-&gt; 3d<BR>Input: 192.168.1.191 =
Hash-&gt;=20
3d<BR>Input: 192.168.1.192 Hash-&gt; 3d<BR>Input: 192.168.1.193 =
Hash-&gt;=20
3d<BR>Input: 192.168.1.194 Hash-&gt; 3d<BR>Input: 192.168.1.195 =
Hash-&gt;=20
3d<BR>Input: 192.168.1.196 Hash-&gt; 3d<BR>Input: 192.168.1.197 =
Hash-&gt;=20
3d<BR>Input: 192.168.1.198 Hash-&gt; 3d<BR>Input: 192.168.1.199 =
Hash-&gt;=20
3d<BR>Input: 192.168.1.200 Hash-&gt; 3d<BR>Input: 192.168.1.201 =
Hash-&gt;=20
3d<BR>Input: 192.168.1.202 Hash-&gt; 3d<BR>Input: 192.168.1.203 =
Hash-&gt;=20
3d<BR>Input: 192.168.1.204 Hash-&gt; 3d<BR>Input: 192.168.1.205 =
Hash-&gt;=20
3d<BR>Input: 192.168.1.206 Hash-&gt; 3d<BR>Input: 192.168.1.207 =
Hash-&gt;=20
3d<BR>Input: 192.168.1.208 Hash-&gt; 3d<BR>Input: 192.168.1.209 =
Hash-&gt;=20
3d<BR>Input: 192.168.1.210 Hash-&gt; 3d<BR>Input: 192.168.1.211 =
Hash-&gt;=20
3d<BR>Input: 192.168.1.212 Hash-&gt; 3d<BR>Input: 192.168.1.213 =
Hash-&gt;=20
3d<BR>Input: 192.168.1.214 Hash-&gt; 3d<BR>Input: 192.168.1.215 =
Hash-&gt;=20
3d<BR>Input: 192.168.1.216 Hash-&gt; 3d<BR>Input: 192.168.1.217 =
Hash-&gt;=20
3d<BR>Input: 192.168.1.218 Hash-&gt; 3d<BR>Input: 192.168.1.219 =
Hash-&gt;=20
3d<BR>Input: 192.168.1.220 Hash-&gt; 3d<BR>Input: 192.168.1.221 =
Hash-&gt;=20
3d<BR>Input: 192.168.1.222 Hash-&gt; 3d<BR>Input: 192.168.1.223 =
Hash-&gt;=20
3d<BR>Input: 192.168.1.224 Hash-&gt; 3d<BR>Input: 192.168.1.225 =
Hash-&gt;=20
3d<BR>Input: 192.168.1.226 Hash-&gt; 3d<BR>Input: 192.168.1.227 =
Hash-&gt;=20
3d<BR>Input: 192.168.1.228 Hash-&gt; 3d<BR>Input: 192.168.1.229 =
Hash-&gt;=20
3d<BR>Input: 192.168.1.230 Hash-&gt; 3d<BR>Input: 192.168.1.231 =
Hash-&gt;=20
3d<BR>Input: 192.168.1.232 Hash-&gt; 3d<BR>Input: 192.168.1.233 =
Hash-&gt;=20
3d<BR>Input: 192.168.1.234 Hash-&gt; 3d<BR>Input: 192.168.1.235 =
Hash-&gt;=20
3d<BR>Input: 192.168.1.236 Hash-&gt; 3d<BR>Input: 192.168.1.237 =
Hash-&gt;=20
3d<BR>Input: 192.168.1.238 Hash-&gt; 3d<BR>Input: 192.168.1.239 =
Hash-&gt;=20
3d<BR>Input: 192.168.1.240 Hash-&gt; 3d<BR>Input: 192.168.1.241 =
Hash-&gt;=20
3d<BR>Input: 192.168.1.242 Hash-&gt; 3d<BR>Input: 192.168.1.243 =
Hash-&gt;=20
3d<BR>Input: 192.168.1.244 Hash-&gt; 3d<BR>Input: 192.168.1.245 =
Hash-&gt;=20
3d<BR>Input: 192.168.1.246 Hash-&gt; 3d<BR>Input: 192.168.1.247 =
Hash-&gt;=20
3d<BR>Input: 192.168.1.248 Hash-&gt; 3d<BR>Input: 192.168.1.249 =
Hash-&gt;=20
3d<BR>Input: 192.168.1.250 Hash-&gt; 3d<BR>Input: 192.168.1.251 =
Hash-&gt;=20
3d<BR>Input: 192.168.1.252 Hash-&gt; 3d<BR>Input: 192.168.1.253 =
Hash-&gt;=20
3d<BR>Input: 192.168.1.254 Hash-&gt; 3d<BR>Input: 192.168.1.255 =
Hash-&gt;=20
3d<BR>Testing byte 2 <BR>Input: 192.169.0.0 Hash-&gt; f6<BR>Input: =
192.169.0.1=20
Hash-&gt; f6<BR>Input: 192.169.0.2 Hash-&gt; f6<BR>Input: 192.169.0.3 =
Hash-&gt;=20
f6<BR>Input: 192.169.0.4 Hash-&gt; f6<BR>Input: 192.169.0.5 Hash-&gt;=20
f6<BR>Input: 192.169.0.6 Hash-&gt; f6<BR>Input: 192.169.0.7 Hash-&gt;=20
f6<BR>Input: 192.169.0.8 Hash-&gt; f6<BR>Input: 192.169.0.9 Hash-&gt;=20
f6<BR>Input: 192.169.0.10 Hash-&gt; f6<BR>Input: 192.169.0.11 Hash-&gt;=20
f6<BR>Input: 192.169.0.12 Hash-&gt; f6<BR>Input: 192.169.0.13 Hash-&gt;=20
f6<BR>Input: 192.169.0.14 Hash-&gt; f6<BR>Input: 192.169.0.15 Hash-&gt;=20
f6<BR>Input: 192.169.0.16 Hash-&gt; f6<BR>Input: 192.169.0.17 Hash-&gt;=20
f6<BR>Input: 192.169.0.18 Hash-&gt; f6<BR>Input: 192.169.0.19 Hash-&gt;=20
f6<BR>Input: 192.169.0.20 Hash-&gt; f6<BR>Input: 192.169.0.21 Hash-&gt;=20
f6<BR>Input: 192.169.0.22 Hash-&gt; f6<BR>Input: 192.169.0.23 Hash-&gt;=20
f6<BR>Input: 192.169.0.24 Hash-&gt; f6<BR>Input: 192.169.0.25 Hash-&gt;=20
f6<BR>Input: 192.169.0.26 Hash-&gt; f6<BR>Input: 192.169.0.27 Hash-&gt;=20
f6<BR>Input: 192.169.0.28 Hash-&gt; f6<BR>Input: 192.169.0.29 Hash-&gt;=20
f6<BR>Input: 192.169.0.30 Hash-&gt; f6<BR>Input: 192.169.0.31 Hash-&gt;=20
f6<BR>Input: 192.169.0.32 Hash-&gt; f6<BR>Input: 192.169.0.33 Hash-&gt;=20
f6<BR>Input: 192.169.0.34 Hash-&gt; f6<BR>Input: 192.169.0.35 Hash-&gt;=20
f6<BR>Input: 192.169.0.36 Hash-&gt; f6<BR>Input: 192.169.0.37 Hash-&gt;=20
f6<BR>Input: 192.169.0.38 Hash-&gt; f6<BR>Input: 192.169.0.39 Hash-&gt;=20
f6<BR>Input: 192.169.0.40 Hash-&gt; f6<BR>Input: 192.169.0.41 Hash-&gt;=20
f6<BR>Input: 192.169.0.42 Hash-&gt; f6<BR>Input: 192.169.0.43 Hash-&gt;=20
f6<BR>Input: 192.169.0.44 Hash-&gt; f6<BR>Input: 192.169.0.45 Hash-&gt;=20
f6<BR>Input: 192.169.0.46 Hash-&gt; f6<BR>Input: 192.169.0.47 Hash-&gt;=20
f6<BR>Input: 192.169.0.48 Hash-&gt; f6<BR>Input: 192.169.0.49 Hash-&gt;=20
f6<BR>Input: 192.169.0.50 Hash-&gt; f6<BR>Input: 192.169.0.51 Hash-&gt;=20
f6<BR>Input: 192.169.0.52 Hash-&gt; f6<BR>Input: 192.169.0.53 Hash-&gt;=20
f6<BR>Input: 192.169.0.54 Hash-&gt; f6<BR>Input: 192.169.0.55 Hash-&gt;=20
f6<BR>Input: 192.169.0.56 Hash-&gt; f6<BR>Input: 192.169.0.57 Hash-&gt;=20
f6<BR>Input: 192.169.0.58 Hash-&gt; f6<BR>Input: 192.169.0.59 Hash-&gt;=20
f6<BR>Input: 192.169.0.60 Hash-&gt; f6<BR>Input: 192.169.0.61 Hash-&gt;=20
f6<BR>Input: 192.169.0.62 Hash-&gt; f6<BR>Input: 192.169.0.63 Hash-&gt;=20
f6<BR>Input: 192.169.0.64 Hash-&gt; f6<BR>Input: 192.169.0.65 Hash-&gt;=20
f6<BR>Input: 192.169.0.66 Hash-&gt; f6<BR>Input: 192.169.0.67 Hash-&gt;=20
f6<BR>Input: 192.169.0.68 Hash-&gt; f6<BR>Input: 192.169.0.69 Hash-&gt;=20
f6<BR>Input: 192.169.0.70 Hash-&gt; f6<BR>Input: 192.169.0.71 Hash-&gt;=20
f6<BR>Input: 192.169.0.72 Hash-&gt; f6<BR>Input: 192.169.0.73 Hash-&gt;=20
f6<BR>Input: 192.169.0.74 Hash-&gt; f6<BR>Input: 192.169.0.75 Hash-&gt;=20
f6<BR>Input: 192.169.0.76 Hash-&gt; f6<BR>Input: 192.169.0.77 Hash-&gt;=20
f6<BR>Input: 192.169.0.78 Hash-&gt; f6<BR>Input: 192.169.0.79 Hash-&gt;=20
f6<BR>Input: 192.169.0.80 Hash-&gt; f6<BR>Input: 192.169.0.81 Hash-&gt;=20
f6<BR>Input: 192.169.0.82 Hash-&gt; f6<BR>Input: 192.169.0.83 Hash-&gt;=20
f6<BR>Input: 192.169.0.84 Hash-&gt; f6<BR>Input: 192.169.0.85 Hash-&gt;=20
f6<BR>Input: 192.169.0.86 Hash-&gt; f6<BR>Input: 192.169.0.87 Hash-&gt;=20
f6<BR>Input: 192.169.0.88 Hash-&gt; f6<BR>Input: 192.169.0.89 Hash-&gt;=20
f6<BR>Input: 192.169.0.90 Hash-&gt; f6<BR>Input: 192.169.0.91 Hash-&gt;=20
f6<BR>Input: 192.169.0.92 Hash-&gt; f6<BR>Input: 192.169.0.93 Hash-&gt;=20
f6<BR>Input: 192.169.0.94 Hash-&gt; f6<BR>Input: 192.169.0.95 Hash-&gt;=20
f6<BR>Input: 192.169.0.96 Hash-&gt; f6<BR>Input: 192.169.0.97 Hash-&gt;=20
f6<BR>Input: 192.169.0.98 Hash-&gt; f6<BR>Input: 192.169.0.99 Hash-&gt;=20
f6<BR>Input: 192.169.0.100 Hash-&gt; f6<BR>Input: 192.169.0.101 =
Hash-&gt;=20
f6<BR>Input: 192.169.0.102 Hash-&gt; f6<BR>Input: 192.169.0.103 =
Hash-&gt;=20
f6<BR>Input: 192.169.0.104 Hash-&gt; f6<BR>Input: 192.169.0.105 =
Hash-&gt;=20
f6<BR>Input: 192.169.0.106 Hash-&gt; f6<BR>Input: 192.169.0.107 =
Hash-&gt;=20
f6<BR>Input: 192.169.0.108 Hash-&gt; f6<BR>Input: 192.169.0.109 =
Hash-&gt;=20
f6<BR>Input: 192.169.0.110 Hash-&gt; f6<BR>Input: 192.169.0.111 =
Hash-&gt;=20
f6<BR>Input: 192.169.0.112 Hash-&gt; f6<BR>Input: 192.169.0.113 =
Hash-&gt;=20
f6<BR>Input: 192.169.0.114 Hash-&gt; f6<BR>Input: 192.169.0.115 =
Hash-&gt;=20
f6<BR>Input: 192.169.0.116 Hash-&gt; f6<BR>Input: 192.169.0.117 =
Hash-&gt;=20
f6<BR>Input: 192.169.0.118 Hash-&gt; f6<BR>Input: 192.169.0.119 =
Hash-&gt;=20
f6<BR>Input: 192.169.0.120 Hash-&gt; f6<BR>Input: 192.169.0.121 =
Hash-&gt;=20
f6<BR>Input: 192.169.0.122 Hash-&gt; f6<BR>Input: 192.169.0.123 =
Hash-&gt;=20
f6<BR>Input: 192.169.0.124 Hash-&gt; f6<BR>Input: 192.169.0.125 =
Hash-&gt;=20
f6<BR>Input: 192.169.0.126 Hash-&gt; f6<BR>Input: 192.169.0.127 =
Hash-&gt;=20
f6<BR>Input: 192.169.0.128 Hash-&gt; f5<BR>Input: 192.169.0.129 =
Hash-&gt;=20
f5<BR>Input: 192.169.0.130 Hash-&gt; f5<BR>Input: 192.169.0.131 =
Hash-&gt;=20
f5<BR>Input: 192.169.0.132 Hash-&gt; f5<BR>Input: 192.169.0.133 =
Hash-&gt;=20
f5<BR>Input: 192.169.0.134 Hash-&gt; f5<BR>Input: 192.169.0.135 =
Hash-&gt;=20
f5<BR>Input: 192.169.0.136 Hash-&gt; f5<BR>Input: 192.169.0.137 =
Hash-&gt;=20
f5<BR>Input: 192.169.0.138 Hash-&gt; f5<BR>Input: 192.169.0.139 =
Hash-&gt;=20
f5<BR>Input: 192.169.0.140 Hash-&gt; f5<BR>Input: 192.169.0.141 =
Hash-&gt;=20
f5<BR>Input: 192.169.0.142 Hash-&gt; f5<BR>Input: 192.169.0.143 =
Hash-&gt;=20
f5<BR>Input: 192.169.0.144 Hash-&gt; f5<BR>Input: 192.169.0.145 =
Hash-&gt;=20
f5<BR>Input: 192.169.0.146 Hash-&gt; f5<BR>Input: 192.169.0.147 =
Hash-&gt;=20
f5<BR>Input: 192.169.0.148 Hash-&gt; f5<BR>Input: 192.169.0.149 =
Hash-&gt;=20
f5<BR>Input: 192.169.0.150 Hash-&gt; f5<BR>Input: 192.169.0.151 =
Hash-&gt;=20
f5<BR>Input: 192.169.0.152 Hash-&gt; f5<BR>Input: 192.169.0.153 =
Hash-&gt;=20
f5<BR>Input: 192.169.0.154 Hash-&gt; f5<BR>Input: 192.169.0.155 =
Hash-&gt;=20
f5<BR>Input: 192.169.0.156 Hash-&gt; f5<BR>Input: 192.169.0.157 =
Hash-&gt;=20
f5<BR>Input: 192.169.0.158 Hash-&gt; f5<BR>Input: 192.169.0.159 =
Hash-&gt;=20
f5<BR>Input: 192.169.0.160 Hash-&gt; f5<BR>Input: 192.169.0.161 =
Hash-&gt;=20
f5<BR>Input: 192.169.0.162 Hash-&gt; f5<BR>Input: 192.169.0.163 =
Hash-&gt;=20
f5<BR>Input: 192.169.0.164 Hash-&gt; f5<BR>Input: 192.169.0.165 =
Hash-&gt;=20
f5<BR>Input: 192.169.0.166 Hash-&gt; f5<BR>Input: 192.169.0.167 =
Hash-&gt;=20
f5<BR>Input: 192.169.0.168 Hash-&gt; f5<BR>Input: 192.169.0.169 =
Hash-&gt;=20
f5<BR>Input: 192.169.0.170 Hash-&gt; f5<BR>Input: 192.169.0.171 =
Hash-&gt;=20
f5<BR>Input: 192.169.0.172 Hash-&gt; f5<BR>Input: 192.169.0.173 =
Hash-&gt;=20
f5<BR>Input: 192.169.0.174 Hash-&gt; f5<BR>Input: 192.169.0.175 =
Hash-&gt;=20
f5<BR>Input: 192.169.0.176 Hash-&gt; f5<BR>Input: 192.169.0.177 =
Hash-&gt;=20
f5<BR>Input: 192.169.0.178 Hash-&gt; f5<BR>Input: 192.169.0.179 =
Hash-&gt;=20
f5<BR>Input: 192.169.0.180 Hash-&gt; f5<BR>Input: 192.169.0.181 =
Hash-&gt;=20
f5<BR>Input: 192.169.0.182 Hash-&gt; f5<BR>Input: 192.169.0.183 =
Hash-&gt;=20
f5<BR>Input: 192.169.0.184 Hash-&gt; f5<BR>Input: 192.169.0.185 =
Hash-&gt;=20
f5<BR>Input: 192.169.0.186 Hash-&gt; f5<BR>Input: 192.169.0.187 =
Hash-&gt;=20
f5<BR>Input: 192.169.0.188 Hash-&gt; f5<BR>Input: 192.169.0.189 =
Hash-&gt;=20
f5<BR>Input: 192.169.0.190 Hash-&gt; f5<BR>Input: 192.169.0.191 =
Hash-&gt;=20
f5<BR>Input: 192.169.0.192 Hash-&gt; f5<BR>Input: 192.169.0.193 =
Hash-&gt;=20
f5<BR>Input: 192.169.0.194 Hash-&gt; f5<BR>Input: 192.169.0.195 =
Hash-&gt;=20
f5<BR>Input: 192.169.0.196 Hash-&gt; f5<BR>Input: 192.169.0.197 =
Hash-&gt;=20
f5<BR>Input: 192.169.0.198 Hash-&gt; f5<BR>Input: 192.169.0.199 =
Hash-&gt;=20
f5<BR>Input: 192.169.0.200 Hash-&gt; f5<BR>Input: 192.169.0.201 =
Hash-&gt;=20
f5<BR>Input: 192.169.0.202 Hash-&gt; f5<BR>Input: 192.169.0.203 =
Hash-&gt;=20
f5<BR>Input: 192.169.0.204 Hash-&gt; f5<BR>Input: 192.169.0.205 =
Hash-&gt;=20
f5<BR>Input: 192.169.0.206 Hash-&gt; f5<BR>Input: 192.169.0.207 =
Hash-&gt;=20
f5<BR>Input: 192.169.0.208 Hash-&gt; f5<BR>Input: 192.169.0.209 =
Hash-&gt;=20
f5<BR>Input: 192.169.0.210 Hash-&gt; f5<BR>Input: 192.169.0.211 =
Hash-&gt;=20
f5<BR>Input: 192.169.0.212 Hash-&gt; f5<BR>Input: 192.169.0.213 =
Hash-&gt;=20
f5<BR>Input: 192.169.0.214 Hash-&gt; f5<BR>Input: 192.169.0.215 =
Hash-&gt;=20
f5<BR>Input: 192.169.0.216 Hash-&gt; f5<BR>Input: 192.169.0.217 =
Hash-&gt;=20
f5<BR>Input: 192.169.0.218 Hash-&gt; f5<BR>Input: 192.169.0.219 =
Hash-&gt;=20
f5<BR>Input: 192.169.0.220 Hash-&gt; f5<BR>Input: 192.169.0.221 =
Hash-&gt;=20
f5<BR>Input: 192.169.0.222 Hash-&gt; f5<BR>Input: 192.169.0.223 =
Hash-&gt;=20
f5<BR>Input: 192.169.0.224 Hash-&gt; f5<BR>Input: 192.169.0.225 =
Hash-&gt;=20
f5<BR>Input: 192.169.0.226 Hash-&gt; f5<BR>Input: 192.169.0.227 =
Hash-&gt;=20
f5<BR>Input: 192.169.0.228 Hash-&gt; f5<BR>Input: 192.169.0.229 =
Hash-&gt;=20
f5<BR>Input: 192.169.0.230 Hash-&gt; f5<BR>Input: 192.169.0.231 =
Hash-&gt;=20
f5<BR>Input: 192.169.0.232 Hash-&gt; f5<BR>Input: 192.169.0.233 =
Hash-&gt;=20
f5<BR>Input: 192.169.0.234 Hash-&gt; f5<BR>Input: 192.169.0.235 =
Hash-&gt;=20
f5<BR>Input: 192.169.0.236 Hash-&gt; f5<BR>Input: 192.169.0.237 =
Hash-&gt;=20
f5<BR>Input: 192.169.0.238 Hash-&gt; f5<BR>Input: 192.169.0.239 =
Hash-&gt;=20
f5<BR>Input: 192.169.0.240 Hash-&gt; f5<BR>Input: 192.169.0.241 =
Hash-&gt;=20
f5<BR>Input: 192.169.0.242 Hash-&gt; f5<BR>Input: 192.169.0.243 =
Hash-&gt;=20
f5<BR>Input: 192.169.0.244 Hash-&gt; f5<BR>Input: 192.169.0.245 =
Hash-&gt;=20
f5<BR>Input: 192.169.0.246 Hash-&gt; f5<BR>Input: 192.169.0.247 =
Hash-&gt;=20
f5<BR>Input: 192.169.0.248 Hash-&gt; f5<BR>Input: 192.169.0.249 =
Hash-&gt;=20
f5<BR>Input: 192.169.0.250 Hash-&gt; f5<BR>Input: 192.169.0.251 =
Hash-&gt;=20
f5<BR>Input: 192.169.0.252 Hash-&gt; f5<BR>Input: 192.169.0.253 =
Hash-&gt;=20
f5<BR>Input: 192.169.0.254 Hash-&gt; f5<BR>Input: 192.169.0.255 =
Hash-&gt;=20
f5<BR>Testing byte 1 (Most significant byte)<BR>Input: 193.169.2.0 =
Hash-&gt;=20
17<BR>Input: 193.169.2.1 Hash-&gt; 17<BR>Input: 193.169.2.2 Hash-&gt;=20
17<BR>Input: 193.169.2.3 Hash-&gt; 17<BR>Input: 193.169.2.4 Hash-&gt;=20
17<BR>Input: 193.169.2.5 Hash-&gt; 17<BR>Input: 193.169.2.6 Hash-&gt;=20
17<BR>Input: 193.169.2.7 Hash-&gt; 17<BR>Input: 193.169.2.8 Hash-&gt;=20
17<BR>Input: 193.169.2.9 Hash-&gt; 17<BR>Input: 193.169.2.10 Hash-&gt;=20
17<BR>Input: 193.169.2.11 Hash-&gt; 17<BR>Input: 193.169.2.12 Hash-&gt;=20
17<BR>Input: 193.169.2.13 Hash-&gt; 17<BR>Input: 193.169.2.14 Hash-&gt;=20
17<BR>Input: 193.169.2.15 Hash-&gt; 17<BR>Input: 193.169.2.16 Hash-&gt;=20
17<BR>Input: 193.169.2.17 Hash-&gt; 17<BR>Input: 193.169.2.18 Hash-&gt;=20
17<BR>Input: 193.169.2.19 Hash-&gt; 17<BR>Input: 193.169.2.20 Hash-&gt;=20
17<BR>Input: 193.169.2.21 Hash-&gt; 17<BR>Input: 193.169.2.22 Hash-&gt;=20
17<BR>Input: 193.169.2.23 Hash-&gt; 17<BR>Input: 193.169.2.24 Hash-&gt;=20
17<BR>Input: 193.169.2.25 Hash-&gt; 17<BR>Input: 193.169.2.26 Hash-&gt;=20
17<BR>Input: 193.169.2.27 Hash-&gt; 17<BR>Input: 193.169.2.28 Hash-&gt;=20
17<BR>Input: 193.169.2.29 Hash-&gt; 17<BR>Input: 193.169.2.30 Hash-&gt;=20
17<BR>Input: 193.169.2.31 Hash-&gt; 17<BR>Input: 193.169.2.32 Hash-&gt;=20
17<BR>Input: 193.169.2.33 Hash-&gt; 17<BR>Input: 193.169.2.34 Hash-&gt;=20
17<BR>Input: 193.169.2.35 Hash-&gt; 17<BR>Input: 193.169.2.36 Hash-&gt;=20
17<BR>Input: 193.169.2.37 Hash-&gt; 17<BR>Input: 193.169.2.38 Hash-&gt;=20
17<BR>Input: 193.169.2.39 Hash-&gt; 17<BR>Input: 193.169.2.40 Hash-&gt;=20
17<BR>Input: 193.169.2.41 Hash-&gt; 17<BR>Input: 193.169.2.42 Hash-&gt;=20
17<BR>Input: 193.169.2.43 Hash-&gt; 17<BR>Input: 193.169.2.44 Hash-&gt;=20
17<BR>Input: 193.169.2.45 Hash-&gt; 17<BR>Input: 193.169.2.46 Hash-&gt;=20
17<BR>Input: 193.169.2.47 Hash-&gt; 17<BR>Input: 193.169.2.48 Hash-&gt;=20
17<BR>Input: 193.169.2.49 Hash-&gt; 17<BR>Input: 193.169.2.50 Hash-&gt;=20
17<BR>Input: 193.169.2.51 Hash-&gt; 17<BR>Input: 193.169.2.52 Hash-&gt;=20
17<BR>Input: 193.169.2.53 Hash-&gt; 17<BR>Input: 193.169.2.54 Hash-&gt;=20
17<BR>Input: 193.169.2.55 Hash-&gt; 17<BR>Input: 193.169.2.56 Hash-&gt;=20
17<BR>Input: 193.169.2.57 Hash-&gt; 17<BR>Input: 193.169.2.58 Hash-&gt;=20
17<BR>Input: 193.169.2.59 Hash-&gt; 17<BR>Input: 193.169.2.60 Hash-&gt;=20
17<BR>Input: 193.169.2.61 Hash-&gt; 17<BR>Input: 193.169.2.62 Hash-&gt;=20
17<BR>Input: 193.169.2.63 Hash-&gt; 17<BR>Input: 193.169.2.64 Hash-&gt;=20
17<BR>Input: 193.169.2.65 Hash-&gt; 17<BR>Input: 193.169.2.66 Hash-&gt;=20
17<BR>Input: 193.169.2.67 Hash-&gt; 17<BR>Input: 193.169.2.68 Hash-&gt;=20
17<BR>Input: 193.169.2.69 Hash-&gt; 17<BR>Input: 193.169.2.70 Hash-&gt;=20
17<BR>Input: 193.169.2.71 Hash-&gt; 17<BR>Input: 193.169.2.72 Hash-&gt;=20
17<BR>Input: 193.169.2.73 Hash-&gt; 17<BR>Input: 193.169.2.74 Hash-&gt;=20
17<BR>Input: 193.169.2.75 Hash-&gt; 17<BR>Input: 193.169.2.76 Hash-&gt;=20
17<BR>Input: 193.169.2.77 Hash-&gt; 17<BR>Input: 193.169.2.78 Hash-&gt;=20
17<BR>Input: 193.169.2.79 Hash-&gt; 17<BR>Input: 193.169.2.80 Hash-&gt;=20
17<BR>Input: 193.169.2.81 Hash-&gt; 17<BR>Input: 193.169.2.82 Hash-&gt;=20
17<BR>Input: 193.169.2.83 Hash-&gt; 17<BR>Input: 193.169.2.84 Hash-&gt;=20
17<BR>Input: 193.169.2.85 Hash-&gt; 17<BR>Input: 193.169.2.86 Hash-&gt;=20
17<BR>Input: 193.169.2.87 Hash-&gt; 17<BR>Input: 193.169.2.88 Hash-&gt;=20
17<BR>Input: 193.169.2.89 Hash-&gt; 17<BR>Input: 193.169.2.90 Hash-&gt;=20
17<BR>Input: 193.169.2.91 Hash-&gt; 17<BR>Input: 193.169.2.92 Hash-&gt;=20
17<BR>Input: 193.169.2.93 Hash-&gt; 17<BR>Input: 193.169.2.94 Hash-&gt;=20
17<BR>Input: 193.169.2.95 Hash-&gt; 17<BR>Input: 193.169.2.96 Hash-&gt;=20
17<BR>Input: 193.169.2.97 Hash-&gt; 17<BR>Input: 193.169.2.98 Hash-&gt;=20
17<BR>Input: 193.169.2.99 Hash-&gt; 17<BR>Input: 193.169.2.100 Hash-&gt; =

17<BR>Input: 193.169.2.101 Hash-&gt; 17<BR>Input: 193.169.2.102 =
Hash-&gt;=20
17<BR>Input: 193.169.2.103 Hash-&gt; 17<BR>Input: 193.169.2.104 =
Hash-&gt;=20
17<BR>Input: 193.169.2.105 Hash-&gt; 17<BR>Input: 193.169.2.106 =
Hash-&gt;=20
17<BR>Input: 193.169.2.107 Hash-&gt; 17<BR>Input: 193.169.2.108 =
Hash-&gt;=20
17<BR>Input: 193.169.2.109 Hash-&gt; 17<BR>Input: 193.169.2.110 =
Hash-&gt;=20
17<BR>Input: 193.169.2.111 Hash-&gt; 17<BR>Input: 193.169.2.112 =
Hash-&gt;=20
17<BR>Input: 193.169.2.113 Hash-&gt; 17<BR>Input: 193.169.2.114 =
Hash-&gt;=20
17<BR>Input: 193.169.2.115 Hash-&gt; 17<BR>Input: 193.169.2.116 =
Hash-&gt;=20
17<BR>Input: 193.169.2.117 Hash-&gt; 17<BR>Input: 193.169.2.118 =
Hash-&gt;=20
17<BR>Input: 193.169.2.119 Hash-&gt; 17<BR>Input: 193.169.2.120 =
Hash-&gt;=20
17<BR>Input: 193.169.2.121 Hash-&gt; 17<BR>Input: 193.169.2.122 =
Hash-&gt;=20
17<BR>Input: 193.169.2.123 Hash-&gt; 17<BR>Input: 193.169.2.124 =
Hash-&gt;=20
17<BR>Input: 193.169.2.125 Hash-&gt; 17<BR>Input: 193.169.2.126 =
Hash-&gt;=20
17<BR>Input: 193.169.2.127 Hash-&gt; 17<BR>Input: 193.169.2.128 =
Hash-&gt;=20
17<BR>Input: 193.169.2.129 Hash-&gt; 17<BR>Input: 193.169.2.130 =
Hash-&gt;=20
17<BR>Input: 193.169.2.131 Hash-&gt; 17<BR>Input: 193.169.2.132 =
Hash-&gt;=20
17<BR>Input: 193.169.2.133 Hash-&gt; 17<BR>Input: 193.169.2.134 =
Hash-&gt;=20
17<BR>Input: 193.169.2.135 Hash-&gt; 17<BR>Input: 193.169.2.136 =
Hash-&gt;=20
17<BR>Input: 193.169.2.137 Hash-&gt; 17<BR>Input: 193.169.2.138 =
Hash-&gt;=20
17<BR>Input: 193.169.2.139 Hash-&gt; 17<BR>Input: 193.169.2.140 =
Hash-&gt;=20
17<BR>Input: 193.169.2.141 Hash-&gt; 17<BR>Input: 193.169.2.142 =
Hash-&gt;=20
17<BR>Input: 193.169.2.143 Hash-&gt; 17<BR>Input: 193.169.2.144 =
Hash-&gt;=20
17<BR>Input: 193.169.2.145 Hash-&gt; 17<BR>Input: 193.169.2.146 =
Hash-&gt;=20
17<BR>Input: 193.169.2.147 Hash-&gt; 17<BR>Input: 193.169.2.148 =
Hash-&gt;=20
17<BR>Input: 193.169.2.149 Hash-&gt; 17<BR>Input: 193.169.2.150 =
Hash-&gt;=20
17<BR>Input: 193.169.2.151 Hash-&gt; 17<BR>Input: 193.169.2.152 =
Hash-&gt;=20
17<BR>Input: 193.169.2.153 Hash-&gt; 17<BR>Input: 193.169.2.154 =
Hash-&gt;=20
17<BR>Input: 193.169.2.155 Hash-&gt; 17<BR>Input: 193.169.2.156 =
Hash-&gt;=20
17<BR>Input: 193.169.2.157 Hash-&gt; 17<BR>Input: 193.169.2.158 =
Hash-&gt;=20
17<BR>Input: 193.169.2.159 Hash-&gt; 17<BR>Input: 193.169.2.160 =
Hash-&gt;=20
17<BR>Input: 193.169.2.161 Hash-&gt; 17<BR>Input: 193.169.2.162 =
Hash-&gt;=20
17<BR>Input: 193.169.2.163 Hash-&gt; 17<BR>Input: 193.169.2.164 =
Hash-&gt;=20
17<BR>Input: 193.169.2.165 Hash-&gt; 17<BR>Input: 193.169.2.166 =
Hash-&gt;=20
17<BR>Input: 193.169.2.167 Hash-&gt; 17<BR>Input: 193.169.2.168 =
Hash-&gt;=20
17<BR>Input: 193.169.2.169 Hash-&gt; 17<BR>Input: 193.169.2.170 =
Hash-&gt;=20
17<BR>Input: 193.169.2.171 Hash-&gt; 17<BR>Input: 193.169.2.172 =
Hash-&gt;=20
17<BR>Input: 193.169.2.173 Hash-&gt; 17<BR>Input: 193.169.2.174 =
Hash-&gt;=20
17<BR>Input: 193.169.2.175 Hash-&gt; 17<BR>Input: 193.169.2.176 =
Hash-&gt;=20
17<BR>Input: 193.169.2.177 Hash-&gt; 17<BR>Input: 193.169.2.178 =
Hash-&gt;=20
17<BR>Input: 193.169.2.179 Hash-&gt; 17<BR>Input: 193.169.2.180 =
Hash-&gt;=20
17<BR>Input: 193.169.2.181 Hash-&gt; 17<BR>Input: 193.169.2.182 =
Hash-&gt;=20
17<BR>Input: 193.169.2.183 Hash-&gt; 17<BR>Input: 193.169.2.184 =
Hash-&gt;=20
17<BR>Input: 193.169.2.185 Hash-&gt; 17<BR>Input: 193.169.2.186 =
Hash-&gt;=20
17<BR>Input: 193.169.2.187 Hash-&gt; 17<BR>Input: 193.169.2.188 =
Hash-&gt;=20
17<BR>Input: 193.169.2.189 Hash-&gt; 17<BR>Input: 193.169.2.190 =
Hash-&gt;=20
17<BR>Input: 193.169.2.191 Hash-&gt; 17<BR>Input: 193.169.2.192 =
Hash-&gt;=20
17<BR>Input: 193.169.2.193 Hash-&gt; 17<BR>Input: 193.169.2.194 =
Hash-&gt;=20
17<BR>Input: 193.169.2.195 Hash-&gt; 17<BR>Input: 193.169.2.196 =
Hash-&gt;=20
17<BR>Input: 193.169.2.197 Hash-&gt; 17<BR>Input: 193.169.2.198 =
Hash-&gt;=20
17<BR>Input: 193.169.2.199 Hash-&gt; 17<BR>Input: 193.169.2.200 =
Hash-&gt;=20
17<BR>Input: 193.169.2.201 Hash-&gt; 17<BR>Input: 193.169.2.202 =
Hash-&gt;=20
17<BR>Input: 193.169.2.203 Hash-&gt; 17<BR>Input: 193.169.2.204 =
Hash-&gt;=20
17<BR>Input: 193.169.2.205 Hash-&gt; 17<BR>Input: 193.169.2.206 =
Hash-&gt;=20
17<BR>Input: 193.169.2.207 Hash-&gt; 17<BR>Input: 193.169.2.208 =
Hash-&gt;=20
17<BR>Input: 193.169.2.209 Hash-&gt; 17<BR>Input: 193.169.2.210 =
Hash-&gt;=20
17<BR>Input: 193.169.2.211 Hash-&gt; 17<BR>Input: 193.169.2.212 =
Hash-&gt;=20
17<BR>Input: 193.169.2.213 Hash-&gt; 17<BR>Input: 193.169.2.214 =
Hash-&gt;=20
17<BR>Input: 193.169.2.215 Hash-&gt; 17<BR>Input: 193.169.2.216 =
Hash-&gt;=20
17<BR>Input: 193.169.2.217 Hash-&gt; 17<BR>Input: 193.169.2.218 =
Hash-&gt;=20
17<BR>Input: 193.169.2.219 Hash-&gt; 17<BR>Input: 193.169.2.220 =
Hash-&gt;=20
17<BR>Input: 193.169.2.221 Hash-&gt; 17<BR>Input: 193.169.2.222 =
Hash-&gt;=20
17<BR>Input: 193.169.2.223 Hash-&gt; 17<BR>Input: 193.169.2.224 =
Hash-&gt;=20
17<BR>Input: 193.169.2.225 Hash-&gt; 17<BR>Input: 193.169.2.226 =
Hash-&gt;=20
17<BR>Input: 193.169.2.227 Hash-&gt; 17<BR>Input: 193.169.2.228 =
Hash-&gt;=20
17</FONT></DIV>
<DIV><FONT face=3DArial size=3D2>Input: 193.169.2.229 Hash-&gt; =
17<BR>Input:=20
193.169.2.230 Hash-&gt; 17<BR>Input: 193.169.2.231 Hash-&gt; =
17<BR>Input:=20
193.169.2.232 Hash-&gt; 17<BR>Input: 193.169.2.233 Hash-&gt; =
17<BR>Input:=20
193.169.2.234 Hash-&gt; 17<BR>Input: 193.169.2.235 Hash-&gt; =
17<BR>Input:=20
193.169.2.236 Hash-&gt; 17<BR>Input: 193.169.2.237 Hash-&gt; =
17<BR>Input:=20
193.169.2.238 Hash-&gt; 17<BR>Input: 193.169.2.239 Hash-&gt; =
17<BR>Input:=20
193.169.2.240 Hash-&gt; 17<BR>Input: 193.169.2.241 Hash-&gt; =
17<BR>Input:=20
193.169.2.242 Hash-&gt; 17<BR>Input: 193.169.2.243 Hash-&gt; =
17<BR>Input:=20
193.169.2.244 Hash-&gt; 17<BR>Input: 193.169.2.245 Hash-&gt; =
17<BR>Input:=20
193.169.2.246 Hash-&gt; 17<BR>Input: 193.169.2.247 Hash-&gt; =
17<BR>Input:=20
193.169.2.248 Hash-&gt; 17<BR>Input: 193.169.2.249 Hash-&gt; =
17<BR>Input:=20
193.169.2.250 Hash-&gt; 17<BR>Input: 193.169.2.251 Hash-&gt; =
17<BR>Input:=20
193.169.2.252 Hash-&gt; 17<BR>Input: 193.169.2.253 Hash-&gt; =
17<BR>Input:=20
193.169.2.254 Hash-&gt; 17<BR>Input: 193.169.2.255 Hash-&gt; =
17</FONT></DIV>
<DIV><FONT face=3DArial size=3D2>------------</FONT></DIV>
<DIV><FONT face=3DArial size=3D2></FONT>&nbsp;</DIV>
<DIV><FONT face=3DArial size=3D2>
<DIV><FONT face=3DArial size=3D2>---------</FONT></DIV>
<DIV><FONT face=3DArial size=3D2></FONT>&nbsp;</DIV>
<DIV><FONT face=3DArial size=3D2>&nbsp;&nbsp;&nbsp; Now you say "Ok =
that's not too=20
cool, but why is this really important ?"</FONT></DIV>
<DIV><FONT face=3DArial size=3D2></FONT>&nbsp;</DIV>
<DIV><FONT face=3DArial =
size=3D2>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; Well, it=20
turns out that the RedHat EL 4 release has some issues</FONT></DIV>
<DIV><FONT face=3DArial size=3D2>&nbsp;&nbsp;&nbsp; with the locking =
around the=20
buckets that this hash is being</FONT></DIV>
<DIV><FONT face=3DArial size=3D2>&nbsp;&nbsp;&nbsp; used to index into, =
and with the=20
distribution being so not... it</FONT></DIV>
<DIV><FONT face=3DArial size=3D2>&nbsp;&nbsp;&nbsp; leads to a lock =
race, followed=20
by a kernel dereference of null,</FONT></DIV>
<DIV><FONT face=3DArial size=3D2>&nbsp;&nbsp;&nbsp; followed shortly by =
angry phone=20
calls.... True, the race needs</FONT></DIV>
<DIV><FONT face=3DArial size=3D2>&nbsp;&nbsp;&nbsp; to be fixed, but it =
sure would=20
be nice if the pressure were a </FONT></DIV>
<DIV><FONT face=3DArial size=3D2>&nbsp;&nbsp;&nbsp; tad lower on the =
lock. It would=20
greatly reduce the probability</FONT></DIV>
<DIV><FONT face=3DArial size=3D2>&nbsp;&nbsp;&nbsp; of the panic, and =
also improve=20
the performance (scaling) of</FONT></DIV>
<DIV><FONT face=3DArial size=3D2>&nbsp;&nbsp;&nbsp; the system, if a few =
more=20
buckets were used :-)</FONT></DIV>
<DIV><FONT face=3DArial size=3D2></FONT>&nbsp;</DIV>
<DIV><FONT face=3DArial size=3D2>&nbsp;&nbsp;&nbsp; I've talked this =
over with=20
Charles, and Bruce, and they pointed</FONT></DIV>
<DIV><FONT face=3DArial size=3D2>&nbsp;&nbsp;&nbsp; me in your direction =
...=20
</FONT></DIV>
<DIV><FONT face=3DArial size=3D2>&nbsp;&nbsp;&nbsp; </FONT></DIV>
<DIV><FONT face=3DArial size=3D2>&nbsp;&nbsp;&nbsp; How would you prefer =
to proceed=20
?</FONT></DIV>
<DIV><FONT face=3DArial size=3D2></FONT>&nbsp;</DIV>
<DIV><FONT face=3DArial size=3D2>&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; =
A. It's your=20
code, and you would prefer to tinker without</FONT></DIV>
<DIV><FONT face=3DArial size=3D2>&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp;=20
&nbsp;&nbsp;&nbsp; some bozo adding his two bits.</FONT></DIV>
<DIV><FONT face=3DArial size=3D2></FONT>&nbsp;</DIV>
<DIV><FONT face=3DArial size=3D2>&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; =
B. You're way=20
too busy to go after this, and would </FONT></DIV>
<DIV><FONT face=3DArial size=3D2>&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp;=20
&nbsp;&nbsp;&nbsp; welcome a diff -u patch.</FONT></DIV>
<DIV><FONT face=3DArial size=3D2></FONT>&nbsp;</DIV>
<DIV><FONT face=3DArial size=3D2>&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; =
C. You'll=20
scratch your head, think about it, and get back</FONT></DIV>
<DIV><FONT face=3DArial size=3D2>&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp;=20
&nbsp;&nbsp;&nbsp; after morning coffee&nbsp;:-)</FONT></DIV>
<DIV>&nbsp;</DIV>
<DIV>&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; D. It will only take a few =
seconds to=20
add the </DIV>
<DIV>&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; =
&nbsp;&nbsp;&nbsp;=20
inet_lnaof( ) to the offending lines, and it will be</DIV>
<DIV>&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp;=20
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; done before you can say Jack =
Flash=20
:-)</DIV>
<DIV>&nbsp;&nbsp;&nbsp; </DIV>
<DIV>&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; E.&nbsp;Go away, you're =
bothering me=20
:-)</DIV>
<DIV><FONT face=3DArial size=3D2></FONT>&nbsp;</DIV>
<DIV><FONT face=3DArial size=3D2>Enjoy,</FONT></DIV>
<DIV><FONT face=3DArial size=3D2>Don Capps</FONT></DIV>
<DIV><FONT face=3DArial size=3D2>capps_at_iozone_dot_org</FONT></DIV>
<DIV><FONT face=3DArial size=3D2>&nbsp;</DIV>
<DIV><BR></DIV></FONT></DIV>
<DIV><BR></DIV></FONT></BODY></HTML>

------=_NextPart_000_00B6_01C600A9.12598ED0--




-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://ads.osdn.com/?ad_id=7637&alloc_id=16865&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
