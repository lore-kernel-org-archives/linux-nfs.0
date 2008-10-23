From: Max Kellermann <max-hDT0AjmEH7RAfugRpC6u6w@public.gmane.org>
Subject: Re: High load in 2.6.27, NFS / rpcauth_lookup_credcache()?
Date: Thu, 23 Oct 2008 14:36:28 +0200
Message-ID: <20081023123628.GA18549@squirrel.roonstrasse.net>
References: <20081022091207.GA12996@squirrel.roonstrasse.net>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="LQksG6bCIzRHxTLp"
Cc: harry-qmPYOCrcNLLyFCzt5hm0YvZ8FUJU4vz8@public.gmane.org
To: linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org,
	trond.myklebust@fys.uio.no
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp2.netcologne.de ([194.8.194.112]:62099 "EHLO
	smtp2.netcologne.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752050AbYJWMgc (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 23 Oct 2008 08:36:32 -0400
In-Reply-To: <20081022091207.GA12996-2pNSKKP3PSJxEiad3KpGLI/oZP4lHnOC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--LQksG6bCIzRHxTLp
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On 2008/10/22 11:12, Max Kellermann <max-hDT0AjmEH7RAfugRpC6u6w@public.gmane.org> wrote:
> after I was able to fix http://lkml.org/lkml/2008/10/17/147, the
> server which was already upgraded to 2.6.27.2 still gets very high
> load.  It is a web server with NFS file storage (NetApp), and while
> the others in the cluster (kernel 2.6.25) have a load of 1-3, 2.6.27.2
> gets 30-50.
> 
> I did an oprofile, with the following results (server just started,
> load "only" 5-10):
> 
> 87593    56.1116  (no location information)   vmlinux
> vmlinux                  rpcauth_lookup_credcache
> 16037    10.2732  auth_generic.c:0            vmlinux
> vmlinux                  generic_match
> 6460      4.1382  (no location information)   php4
> php4                     (no symbols)
> 2478      1.5874  (no location information)   libc-2.7.so
> libc-2.7.so              (no symbols)
> [...]
> 
> We havn't configured any special authentication method.  It is a NFSv3
> over UDP mount, but the kernel has NFSv4 and therefore KRB5 enabled.
> 
> Any ideas why rpcauth_lookup_credcache() goes overboard with CPU
> usage?

I have bisected the problem: 98a8e323 is the result ("SUNRPC: Add a
helper rpcauth_lookup_generic_cred()").  5c691044 is ok.

See the attached oprofile annotation data for both commits.  I guess
that the function rpcauth_lookup_credcache() is waiting for a spinlock
too often and too long.  Trond, any idea?

Harry: added you to Cc because your problem sounds similar.

Max

--LQksG6bCIzRHxTLp
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="annotate.98a8e3239427051f5d44f2025b398bdcc3918f37"

/* 
 * Command line: opannotate -a -i rpcauth_lookup_credcache vmlinux 
 * 
 * Interpretation of command line:
 * Output annotated assembly listing with samples
 * 
 * CPU: P4 / Xeon with 2 hyper-threads, speed 2400 MHz (estimated)
 * Counted GLOBAL_POWER_EVENTS events (time during which processor is not stopped) with a unit mask of 0x01 (mandatory) count 100000
 */
               :
               :/root/vmlinux:     file format elf32-i386
               :
               :Disassembly of section .text.head:
               :Disassembly of section .text:
               :
c03f7074 <rpcauth_lookup_credcache>: /* rpcauth_lookup_credcache total: 905790 100.000 */
  1525  0.1684 :c03f7074:	push   %ebp
   140  0.0155 :c03f7075:	mov    %esp,%ebp
    22  0.0024 :c03f7077:	push   %edi
    81  0.0089 :c03f7078:	push   %esi
    52  0.0057 :c03f7079:	push   %ebx
    38  0.0042 :c03f707a:	sub    $0x1c,%esp
               :c03f707d:	mov    %eax,0xffffffe0(%ebp)
   156  0.0172 :c03f7080:	mov    %edx,0xffffffdc(%ebp)
    67  0.0074 :c03f7083:	mov    %ecx,0xffffffd8(%ebp)
     5 5.5e-04 :c03f7086:	lea    0xffffffec(%ebp),%eax
    21  0.0023 :c03f7089:	mov    %eax,0xffffffec(%ebp)
    75  0.0083 :c03f708c:	mov    %eax,0xfffffff0(%ebp)
    16  0.0018 :c03f708f:	mov    0xffffffe0(%ebp),%eax
    60  0.0066 :c03f7092:	mov    0x1c(%eax),%eax
   101  0.0112 :c03f7095:	mov    %eax,0xffffffe4(%ebp)
    12  0.0013 :c03f7098:	imul   $0x9e370001,(%edx),%edx
   273  0.0301 :c03f709e:	shr    $0x1c,%edx
    38  0.0042 :c03f70a1:	mov    %edx,0xffffffe8(%ebp)
    64  0.0071 :c03f70a4:	mov    (%eax,%edx,4),%esi
  1254  0.1384 :c03f70a7:	jmp    c03f70ca <rpcauth_lookup_credcache+0x56>
   620  0.0684 :c03f70a9:	mov    0xffffffe4(%ebp),%eax
   132  0.0146 :c03f70ac:	add    $0x40,%eax
    20  0.0022 :c03f70af:	call   c0435d3e <_spin_lock>
  4039  0.4459 :c03f70b4:	testb  $0x4,0x28(%esi)
    34  0.0038 :c03f70b8:	jne    c03f70c2 <rpcauth_lookup_credcache+0x4e>
               :c03f70ba:	mov    0xffffffe4(%ebp),%ecx
               :c03f70bd:	incb   0x40(%ecx)
               :c03f70c0:	jmp    c03f70c8 <rpcauth_lookup_credcache+0x54>
    44  0.0049 :c03f70c2:	lock incl 0x2c(%esi)
  3854  0.4255 :c03f70c6:	jmp    c03f7147 <rpcauth_lookup_credcache+0xd3>
 11816  1.3045 :c03f70c8:	mov    (%esi),%esi
  5214  0.5756 :c03f70ca:	test   %esi,%esi
  1082  0.1195 :c03f70cc:	je     c03f719e <rpcauth_lookup_credcache+0x12a>
 22189  2.4497 :c03f70d2:	mov    (%esi),%eax
702721 77.5810 :c03f70d4:	(bad)  
               :c03f70d6:	inc    %eax
 43523  4.8050 :c03f70d7:	add    %cl,0x4d8b1c5e(%ebx)
               :c03f70dd:	fmuls  0xdc458bf2(%ecx)
  3752  0.4142 :c03f70e3:	call   *0xc(%ebx)
 22791  2.5161 :c03f70e6:	test   %eax,%eax
 10130  1.1184 :c03f70e8:	je     c03f70c8 <rpcauth_lookup_credcache+0x54>
   217  0.0240 :c03f70ea:	jmp    c03f70a9 <rpcauth_lookup_credcache+0x35>
               :c03f70ec:	mov    0xffffffe4(%ebp),%eax
               :c03f70ef:	add    $0x40,%eax
               :c03f70f2:	call   c0435d3e <_spin_lock>
     4 4.4e-04 :c03f70f7:	mov    0xffffffe8(%ebp),%edx
               :c03f70fa:	mov    0xffffffe4(%ebp),%ecx
               :c03f70fd:	mov    (%ecx,%edx,4),%esi
               :c03f7100:	jmp    c03f711e <rpcauth_lookup_credcache+0xaa>
               :c03f7102:	lock incl 0x2c(%esi)
               :c03f7106:	mov    0xfffffff0(%ebp),%ecx
               :c03f7109:	lea    0x8(%edi),%edx
               :c03f710c:	mov    %edx,0xfffffff0(%ebp)
               :c03f710f:	lea    0xffffffec(%ebp),%eax
               :c03f7112:	mov    %eax,0x8(%edi)
               :c03f7115:	mov    %ecx,0x4(%edx)
               :c03f7118:	mov    %edx,(%ecx)
               :c03f711a:	jmp    c03f7147 <rpcauth_lookup_credcache+0xd3>
    20  0.0022 :c03f711c:	mov    (%esi),%esi
               :c03f711e:	test   %esi,%esi
               :c03f7120:	je     c03f71c0 <rpcauth_lookup_credcache+0x14c>
    19  0.0021 :c03f7126:	mov    (%esi),%eax
  1279  0.1412 :c03f7128:	(bad)  
               :c03f712a:	inc    %eax
    59  0.0065 :c03f712b:	add    %cl,0x4d8b1c5e(%ebx)
               :c03f7131:	fmuls  0xdc458bf2(%ecx)
     3 3.3e-04 :c03f7137:	call   *0xc(%ebx)
    22  0.0024 :c03f713a:	test   %eax,%eax
    18  0.0020 :c03f713c:	je     c03f711c <rpcauth_lookup_credcache+0xa8>
               :c03f713e:	jmp    c03f7102 <rpcauth_lookup_credcache+0x8e>
               :c03f7140:	mov    %edi,0x4(%eax)
               :c03f7143:	mov    %edi,(%edx)
               :c03f7145:	mov    %edi,%esi
    14  0.0015 :c03f7147:	mov    0xffffffe4(%ebp),%eax
    11  0.0012 :c03f714a:	incb   0x40(%eax)
    76  0.0084 :c03f714d:	testb  $0x1,0x28(%esi)
   109  0.0120 :c03f7151:	je     c03f7192 <rpcauth_lookup_credcache+0x11e>
               :c03f7153:	mov    0x1c(%esi),%eax
               :c03f7156:	mov    0x4(%eax),%ecx
               :c03f7159:	test   %ecx,%ecx
               :c03f715b:	je     c03f7192 <rpcauth_lookup_credcache+0x11e>
               :c03f715d:	testb  $0x1,0xffffffd8(%ebp)
               :c03f7161:	jne    c03f7192 <rpcauth_lookup_credcache+0x11e>
               :c03f7163:	mov    %esi,%edx
               :c03f7165:	mov    0xffffffe0(%ebp),%eax
               :c03f7168:	call   *%ecx
               :c03f716a:	mov    %eax,%ebx
               :c03f716c:	test   %eax,%eax
               :c03f716e:	jns    c03f7192 <rpcauth_lookup_credcache+0x11e>
               :c03f7170:	mov    %esi,%eax
               :c03f7172:	call   c03f6caa <put_rpccred>
               :c03f7177:	mov    %ebx,%esi
               :c03f7179:	jmp    c03f7192 <rpcauth_lookup_credcache+0x11e>
               :c03f717b:	lea    0xfffffff8(%ebx),%eax
               :c03f717e:	mov    (%ebx),%ecx
               :c03f7180:	mov    0x4(%ebx),%edx
               :c03f7183:	mov    %edx,0x4(%ecx)
               :c03f7186:	mov    %ecx,(%edx)
               :c03f7188:	mov    %ebx,(%ebx)
               :c03f718a:	mov    %ebx,0x4(%ebx)
               :c03f718d:	call   c03f6caa <put_rpccred>
   100  0.0110 :c03f7192:	mov    0xffffffec(%ebp),%ebx
    45  0.0050 :c03f7195:	lea    0xffffffec(%ebp),%eax
     5 5.5e-04 :c03f7198:	cmp    %eax,%ebx
    49  0.0054 :c03f719a:	jne    c03f717b <rpcauth_lookup_credcache+0x107>
    29  0.0032 :c03f719c:	jmp    c03f71e3 <rpcauth_lookup_credcache+0x16f>
     1 1.1e-04 :c03f719e:	mov    0xffffffe0(%ebp),%edx
               :c03f71a1:	mov    0x10(%edx),%ebx
     2 2.2e-04 :c03f71a4:	mov    0xffffffd8(%ebp),%ecx
               :c03f71a7:	mov    0xffffffdc(%ebp),%edx
               :c03f71aa:	mov    0xffffffe0(%ebp),%eax
               :c03f71ad:	call   *0x18(%ebx)
               :c03f71b0:	mov    %eax,%edi
               :c03f71b2:	mov    %eax,%esi
               :c03f71b4:	cmp    $0xfffff000,%eax
               :c03f71b9:	ja     c03f71e3 <rpcauth_lookup_credcache+0x16f>
               :c03f71bb:	jmp    c03f70ec <rpcauth_lookup_credcache+0x78>
               :c03f71c0:	lock btsl $0x2,0x28(%edi)
     1 1.1e-04 :c03f71c6:	mov    0xffffffe8(%ebp),%ecx
               :c03f71c9:	mov    0xffffffe4(%ebp),%eax
               :c03f71cc:	lea    (%eax,%ecx,4),%edx
               :c03f71cf:	mov    (%edx),%eax
               :c03f71d1:	mov    %eax,(%edi)
               :c03f71d3:	mov    %edx,0x4(%edi)
               :c03f71d6:	test   %eax,%eax
               :c03f71d8:	jne    c03f7140 <rpcauth_lookup_credcache+0xcc>
               :c03f71de:	jmp    c03f7143 <rpcauth_lookup_credcache+0xcf>
    58  0.0064 :c03f71e3:	mov    %esi,%eax
    17  0.0019 :c03f71e5:	add    $0x1c,%esp
    13  0.0014 :c03f71e8:	pop    %ebx
    45  0.0050 :c03f71e9:	pop    %esi
    17  0.0019 :c03f71ea:	pop    %edi
     5 5.5e-04 :c03f71eb:	pop    %ebp
    38  0.0042 :c03f71ec:	ret    
               :Disassembly of section .init.text:
               :Disassembly of section .altinstr_replacement:
               :Disassembly of section .exit.text:

--LQksG6bCIzRHxTLp
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="annotate.5c691044ecbca04dd558fca4c754121689fe1b34"

/* 
 * Command line: opannotate -a -i rpcauth_lookup_credcache vmlinux 
 * 
 * Interpretation of command line:
 * Output annotated assembly listing with samples
 * 
 * CPU: P4 / Xeon with 2 hyper-threads, speed 2400 MHz (estimated)
 * Counted GLOBAL_POWER_EVENTS events (time during which processor is not stopped) with a unit mask of 0x01 (mandatory) count 100000
 */
               :
               :/root/vmlinux:     file format elf32-i386
               :
               :Disassembly of section .text.head:
               :Disassembly of section .text:
               :
c03f7104 <rpcauth_lookup_credcache>: /* rpcauth_lookup_credcache total:    435 100.000 */
    21  4.8276 :c03f7104:	push   %ebp
     2  0.4598 :c03f7105:	mov    %esp,%ebp
               :c03f7107:	push   %edi
               :c03f7108:	push   %esi
     1  0.2299 :c03f7109:	push   %ebx
               :c03f710a:	sub    $0x1c,%esp
               :c03f710d:	mov    %eax,0xffffffe0(%ebp)
     1  0.2299 :c03f7110:	mov    %edx,0xffffffdc(%ebp)
               :c03f7113:	mov    %ecx,0xffffffd8(%ebp)
               :c03f7116:	lea    0xffffffec(%ebp),%eax
     1  0.2299 :c03f7119:	mov    %eax,0xffffffec(%ebp)
     2  0.4598 :c03f711c:	mov    %eax,0xfffffff0(%ebp)
               :c03f711f:	mov    0xffffffe0(%ebp),%eax
     3  0.6897 :c03f7122:	mov    0x1c(%eax),%eax
     3  0.6897 :c03f7125:	mov    %eax,0xffffffe4(%ebp)
               :c03f7128:	imul   $0x9e370001,(%edx),%edx
     4  0.9195 :c03f712e:	shr    $0x1c,%edx
     2  0.4598 :c03f7131:	mov    %edx,0xffffffe8(%ebp)
     2  0.4598 :c03f7134:	mov    (%eax,%edx,4),%esi
    39  8.9655 :c03f7137:	jmp    c03f715a <rpcauth_lookup_credcache+0x56>
    10  2.2989 :c03f7139:	mov    0xffffffe4(%ebp),%eax
     1  0.2299 :c03f713c:	add    $0x40,%eax
     1  0.2299 :c03f713f:	call   c0435dce <_spin_lock>
   134 30.8046 :c03f7144:	testb  $0x4,0x28(%esi)
     2  0.4598 :c03f7148:	jne    c03f7152 <rpcauth_lookup_credcache+0x4e>
               :c03f714a:	mov    0xffffffe4(%ebp),%ecx
               :c03f714d:	incb   0x40(%ecx)
               :c03f7150:	jmp    c03f7158 <rpcauth_lookup_credcache+0x54>
     3  0.6897 :c03f7152:	lock incl 0x2c(%esi)
   110 25.2874 :c03f7156:	jmp    c03f71d7 <rpcauth_lookup_credcache+0xd3>
     2  0.4598 :c03f7158:	mov    (%esi),%esi
     6  1.3793 :c03f715a:	test   %esi,%esi
               :c03f715c:	je     c03f722e <rpcauth_lookup_credcache+0x12a>
               :c03f7162:	mov    (%esi),%eax
    43  9.8851 :c03f7164:	(bad)  
               :c03f7166:	inc    %eax
    10  2.2989 :c03f7167:	add    %cl,0x4d8b1c5e(%ebx)
               :c03f716d:	fmuls  0xdc458bf2(%ecx)
               :c03f7173:	call   *0xc(%ebx)
     4  0.9195 :c03f7176:	test   %eax,%eax
     6  1.3793 :c03f7178:	je     c03f7158 <rpcauth_lookup_credcache+0x54>
     2  0.4598 :c03f717a:	jmp    c03f7139 <rpcauth_lookup_credcache+0x35>
               :c03f717c:	mov    0xffffffe4(%ebp),%eax
               :c03f717f:	add    $0x40,%eax
               :c03f7182:	call   c0435dce <_spin_lock>
               :c03f7187:	mov    0xffffffe8(%ebp),%edx
               :c03f718a:	mov    0xffffffe4(%ebp),%ecx
               :c03f718d:	mov    (%ecx,%edx,4),%esi
               :c03f7190:	jmp    c03f71ae <rpcauth_lookup_credcache+0xaa>
               :c03f7192:	lock incl 0x2c(%esi)
               :c03f7196:	mov    0xfffffff0(%ebp),%ecx
               :c03f7199:	lea    0x8(%edi),%edx
               :c03f719c:	mov    %edx,0xfffffff0(%ebp)
               :c03f719f:	lea    0xffffffec(%ebp),%eax
               :c03f71a2:	mov    %eax,0x8(%edi)
               :c03f71a5:	mov    %ecx,0x4(%edx)
               :c03f71a8:	mov    %edx,(%ecx)
               :c03f71aa:	jmp    c03f71d7 <rpcauth_lookup_credcache+0xd3>
               :c03f71ac:	mov    (%esi),%esi
               :c03f71ae:	test   %esi,%esi
               :c03f71b0:	je     c03f7250 <rpcauth_lookup_credcache+0x14c>
               :c03f71b6:	mov    (%esi),%eax
               :c03f71b8:	(bad)  
               :c03f71ba:	inc    %eax
               :c03f71bb:	add    %cl,0x4d8b1c5e(%ebx)
               :c03f71c1:	fmuls  0xdc458bf2(%ecx)
               :c03f71c7:	call   *0xc(%ebx)
               :c03f71ca:	test   %eax,%eax
               :c03f71cc:	je     c03f71ac <rpcauth_lookup_credcache+0xa8>
               :c03f71ce:	jmp    c03f7192 <rpcauth_lookup_credcache+0x8e>
               :c03f71d0:	mov    %edi,0x4(%eax)
               :c03f71d3:	mov    %edi,(%edx)
               :c03f71d5:	mov    %edi,%esi
               :c03f71d7:	mov    0xffffffe4(%ebp),%eax
     1  0.2299 :c03f71da:	incb   0x40(%eax)
     1  0.2299 :c03f71dd:	testb  $0x1,0x28(%esi)
     2  0.4598 :c03f71e1:	je     c03f7222 <rpcauth_lookup_credcache+0x11e>
               :c03f71e3:	mov    0x1c(%esi),%eax
               :c03f71e6:	mov    0x4(%eax),%ecx
               :c03f71e9:	test   %ecx,%ecx
               :c03f71eb:	je     c03f7222 <rpcauth_lookup_credcache+0x11e>
               :c03f71ed:	testb  $0x1,0xffffffd8(%ebp)
               :c03f71f1:	jne    c03f7222 <rpcauth_lookup_credcache+0x11e>
               :c03f71f3:	mov    %esi,%edx
               :c03f71f5:	mov    0xffffffe0(%ebp),%eax
               :c03f71f8:	call   *%ecx
               :c03f71fa:	mov    %eax,%ebx
               :c03f71fc:	test   %eax,%eax
               :c03f71fe:	jns    c03f7222 <rpcauth_lookup_credcache+0x11e>
               :c03f7200:	mov    %esi,%eax
               :c03f7202:	call   c03f6d3a <put_rpccred>
               :c03f7207:	mov    %ebx,%esi
               :c03f7209:	jmp    c03f7222 <rpcauth_lookup_credcache+0x11e>
               :c03f720b:	lea    0xfffffff8(%ebx),%eax
               :c03f720e:	mov    (%ebx),%ecx
               :c03f7210:	mov    0x4(%ebx),%edx
               :c03f7213:	mov    %edx,0x4(%ecx)
               :c03f7216:	mov    %ecx,(%edx)
               :c03f7218:	mov    %ebx,(%ebx)
               :c03f721a:	mov    %ebx,0x4(%ebx)
               :c03f721d:	call   c03f6d3a <put_rpccred>
     2  0.4598 :c03f7222:	mov    0xffffffec(%ebp),%ebx
     2  0.4598 :c03f7225:	lea    0xffffffec(%ebp),%eax
               :c03f7228:	cmp    %eax,%ebx
     1  0.2299 :c03f722a:	jne    c03f720b <rpcauth_lookup_credcache+0x107>
     3  0.6897 :c03f722c:	jmp    c03f7273 <rpcauth_lookup_credcache+0x16f>
               :c03f722e:	mov    0xffffffe0(%ebp),%edx
               :c03f7231:	mov    0x10(%edx),%ebx
               :c03f7234:	mov    0xffffffd8(%ebp),%ecx
               :c03f7237:	mov    0xffffffdc(%ebp),%edx
               :c03f723a:	mov    0xffffffe0(%ebp),%eax
               :c03f723d:	call   *0x18(%ebx)
               :c03f7240:	mov    %eax,%edi
               :c03f7242:	mov    %eax,%esi
               :c03f7244:	cmp    $0xfffff000,%eax
               :c03f7249:	ja     c03f7273 <rpcauth_lookup_credcache+0x16f>
               :c03f724b:	jmp    c03f717c <rpcauth_lookup_credcache+0x78>
               :c03f7250:	lock btsl $0x2,0x28(%edi)
               :c03f7256:	mov    0xffffffe8(%ebp),%ecx
               :c03f7259:	mov    0xffffffe4(%ebp),%eax
               :c03f725c:	lea    (%eax,%ecx,4),%edx
               :c03f725f:	mov    (%edx),%eax
               :c03f7261:	mov    %eax,(%edi)
               :c03f7263:	mov    %edx,0x4(%edi)
               :c03f7266:	test   %eax,%eax
               :c03f7268:	jne    c03f71d0 <rpcauth_lookup_credcache+0xcc>
               :c03f726e:	jmp    c03f71d3 <rpcauth_lookup_credcache+0xcf>
     4  0.9195 :c03f7273:	mov    %esi,%eax
               :c03f7275:	add    $0x1c,%esp
               :c03f7278:	pop    %ebx
     1  0.2299 :c03f7279:	pop    %esi
     1  0.2299 :c03f727a:	pop    %edi
               :c03f727b:	pop    %ebp
               :c03f727c:	ret    
               :Disassembly of section .init.text:
               :Disassembly of section .altinstr_replacement:
               :Disassembly of section .exit.text:

--LQksG6bCIzRHxTLp--
