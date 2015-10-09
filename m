Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:43504 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751014AbbJIBI5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 8 Oct 2015 21:08:57 -0400
Date: Fri, 9 Oct 2015 09:08:14 +0800
From: kbuild test robot <lkp@intel.com>
To: Kosuke Tatsukawa <tatsu@ab.jp.nec.com>
Cc: kbuild-all@01.org, Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@poochiereds.net>,
        "David S. Miller" <davem@davemloft.net>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH] sunrpc: fix waitqueue_active without memory barrier in
 sunrpc
Message-ID: <201510090927.3pvFRb8U%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="BXVAT5kNtrzKuDFl"
In-Reply-To: <17EC94B0A072C34B8DCF0D30AD16044A028747A3@BPXM09GP.gisp.nec.co.jp>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--BXVAT5kNtrzKuDFl
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Kosuke,

[auto build test WARNING on v4.3-rc4 -- if it's inappropriate base, please ignore]

config: x86_64-randconfig-x002-201540 (attached as .config)
reproduce:
        # save the attached .config to linux build tree
        make ARCH=x86_64 

All warnings (new ones prefixed by >>):

   In file included from include/linux/linkage.h:4:0,
                    from include/linux/kernel.h:6,
                    from net/sunrpc/svcsock.c:22:
   net/sunrpc/svcsock.c: In function 'svc_udp_data_ready':
   net/sunrpc/svcsock.c:417:21: warning: passing argument 1 of 'wq_has_sleeper' from incompatible pointer type [-Wincompatible-pointer-types]
     if (wq_has_sleeper(wq))
                        ^
   include/linux/compiler.h:147:28: note: in definition of macro '__trace_if'
     if (__builtin_constant_p((cond)) ? !!(cond) :   \
                               ^
>> net/sunrpc/svcsock.c:417:2: note: in expansion of macro 'if'
     if (wq_has_sleeper(wq))
     ^
   In file included from include/net/inet_sock.h:27:0,
                    from include/linux/udp.h:20,
                    from net/sunrpc/svcsock.c:30:
   include/net/sock.h:1879:20: note: expected 'struct socket_wq *' but argument is of type 'wait_queue_head_t * {aka struct __wait_queue_head *}'
    static inline bool wq_has_sleeper(struct socket_wq *wq)
                       ^
   In file included from include/linux/linkage.h:4:0,
                    from include/linux/kernel.h:6,
                    from net/sunrpc/svcsock.c:22:
   net/sunrpc/svcsock.c:417:21: warning: passing argument 1 of 'wq_has_sleeper' from incompatible pointer type [-Wincompatible-pointer-types]
     if (wq_has_sleeper(wq))
                        ^
   include/linux/compiler.h:147:40: note: in definition of macro '__trace_if'
     if (__builtin_constant_p((cond)) ? !!(cond) :   \
                                           ^
>> net/sunrpc/svcsock.c:417:2: note: in expansion of macro 'if'
     if (wq_has_sleeper(wq))
     ^
   In file included from include/net/inet_sock.h:27:0,
                    from include/linux/udp.h:20,
                    from net/sunrpc/svcsock.c:30:
   include/net/sock.h:1879:20: note: expected 'struct socket_wq *' but argument is of type 'wait_queue_head_t * {aka struct __wait_queue_head *}'
    static inline bool wq_has_sleeper(struct socket_wq *wq)
                       ^
   In file included from include/linux/linkage.h:4:0,
                    from include/linux/kernel.h:6,
                    from net/sunrpc/svcsock.c:22:
   net/sunrpc/svcsock.c:417:21: warning: passing argument 1 of 'wq_has_sleeper' from incompatible pointer type [-Wincompatible-pointer-types]
     if (wq_has_sleeper(wq))
                        ^
   include/linux/compiler.h:158:16: note: in definition of macro '__trace_if'
      ______r = !!(cond);     \
                   ^
>> net/sunrpc/svcsock.c:417:2: note: in expansion of macro 'if'
     if (wq_has_sleeper(wq))
     ^
   In file included from include/net/inet_sock.h:27:0,
                    from include/linux/udp.h:20,
                    from net/sunrpc/svcsock.c:30:
   include/net/sock.h:1879:20: note: expected 'struct socket_wq *' but argument is of type 'wait_queue_head_t * {aka struct __wait_queue_head *}'
    static inline bool wq_has_sleeper(struct socket_wq *wq)
                       ^
   In file included from include/linux/linkage.h:4:0,
                    from include/linux/kernel.h:6,
                    from net/sunrpc/svcsock.c:22:
   net/sunrpc/svcsock.c: In function 'svc_write_space':
   net/sunrpc/svcsock.c:435:21: warning: passing argument 1 of 'wq_has_sleeper' from incompatible pointer type [-Wincompatible-pointer-types]
     if (wq_has_sleeper(wq)) {
                        ^
   include/linux/compiler.h:147:28: note: in definition of macro '__trace_if'
     if (__builtin_constant_p((cond)) ? !!(cond) :   \
                               ^
   net/sunrpc/svcsock.c:435:2: note: in expansion of macro 'if'
     if (wq_has_sleeper(wq)) {
     ^
   In file included from include/net/inet_sock.h:27:0,
                    from include/linux/udp.h:20,
                    from net/sunrpc/svcsock.c:30:
   include/net/sock.h:1879:20: note: expected 'struct socket_wq *' but argument is of type 'wait_queue_head_t * {aka struct __wait_queue_head *}'
    static inline bool wq_has_sleeper(struct socket_wq *wq)
                       ^
   In file included from include/linux/linkage.h:4:0,
                    from include/linux/kernel.h:6,
                    from net/sunrpc/svcsock.c:22:
   net/sunrpc/svcsock.c:435:21: warning: passing argument 1 of 'wq_has_sleeper' from incompatible pointer type [-Wincompatible-pointer-types]
     if (wq_has_sleeper(wq)) {
                        ^
   include/linux/compiler.h:147:40: note: in definition of macro '__trace_if'
     if (__builtin_constant_p((cond)) ? !!(cond) :   \
                                           ^
   net/sunrpc/svcsock.c:435:2: note: in expansion of macro 'if'
     if (wq_has_sleeper(wq)) {
     ^
   In file included from include/net/inet_sock.h:27:0,
                    from include/linux/udp.h:20,
                    from net/sunrpc/svcsock.c:30:
   include/net/sock.h:1879:20: note: expected 'struct socket_wq *' but argument is of type 'wait_queue_head_t * {aka struct __wait_queue_head *}'
    static inline bool wq_has_sleeper(struct socket_wq *wq)
                       ^
   In file included from include/linux/linkage.h:4:0,
                    from include/linux/kernel.h:6,
                    from net/sunrpc/svcsock.c:22:
   net/sunrpc/svcsock.c:435:21: warning: passing argument 1 of 'wq_has_sleeper' from incompatible pointer type [-Wincompatible-pointer-types]
     if (wq_has_sleeper(wq)) {
                        ^
   include/linux/compiler.h:158:16: note: in definition of macro '__trace_if'
      ______r = !!(cond);     \
                   ^
   net/sunrpc/svcsock.c:435:2: note: in expansion of macro 'if'
     if (wq_has_sleeper(wq)) {
     ^
   In file included from include/net/inet_sock.h:27:0,
                    from include/linux/udp.h:20,
                    from net/sunrpc/svcsock.c:30:
   include/net/sock.h:1879:20: note: expected 'struct socket_wq *' but argument is of type 'wait_queue_head_t * {aka struct __wait_queue_head *}'
    static inline bool wq_has_sleeper(struct socket_wq *wq)
                       ^
   In file included from include/linux/linkage.h:4:0,
                    from include/linux/kernel.h:6,
                    from net/sunrpc/svcsock.c:22:
   net/sunrpc/svcsock.c: In function 'svc_tcp_listen_data_ready':
   net/sunrpc/svcsock.c:790:21: warning: passing argument 1 of 'wq_has_sleeper' from incompatible pointer type [-Wincompatible-pointer-types]
     if (wq_has_sleeper(wq))
                        ^
   include/linux/compiler.h:147:28: note: in definition of macro '__trace_if'
     if (__builtin_constant_p((cond)) ? !!(cond) :   \
                               ^
   net/sunrpc/svcsock.c:790:2: note: in expansion of macro 'if'
     if (wq_has_sleeper(wq))
     ^
   In file included from include/net/inet_sock.h:27:0,
                    from include/linux/udp.h:20,
                    from net/sunrpc/svcsock.c:30:
   include/net/sock.h:1879:20: note: expected 'struct socket_wq *' but argument is of type 'wait_queue_head_t * {aka struct __wait_queue_head *}'
    static inline bool wq_has_sleeper(struct socket_wq *wq)
                       ^
   In file included from include/linux/linkage.h:4:0,
                    from include/linux/kernel.h:6,
                    from net/sunrpc/svcsock.c:22:
   net/sunrpc/svcsock.c:790:21: warning: passing argument 1 of 'wq_has_sleeper' from incompatible pointer type [-Wincompatible-pointer-types]
     if (wq_has_sleeper(wq))
                        ^
   include/linux/compiler.h:147:40: note: in definition of macro '__trace_if'
     if (__builtin_constant_p((cond)) ? !!(cond) :   \
                                           ^
   net/sunrpc/svcsock.c:790:2: note: in expansion of macro 'if'
     if (wq_has_sleeper(wq))
     ^
   In file included from include/net/inet_sock.h:27:0,
                    from include/linux/udp.h:20,
                    from net/sunrpc/svcsock.c:30:
   include/net/sock.h:1879:20: note: expected 'struct socket_wq *' but argument is of type 'wait_queue_head_t * {aka struct __wait_queue_head *}'
    static inline bool wq_has_sleeper(struct socket_wq *wq)
                       ^

vim +/if +417 net/sunrpc/svcsock.c

   401	
   402	/*
   403	 * INET callback when data has been received on the socket.
   404	 */
   405	static void svc_udp_data_ready(struct sock *sk)
   406	{
   407		struct svc_sock	*svsk = (struct svc_sock *)sk->sk_user_data;
   408		wait_queue_head_t *wq = sk_sleep(sk);
   409	
   410		if (svsk) {
   411			dprintk("svc: socket %p(inet %p), busy=%d\n",
   412				svsk, sk,
   413				test_bit(XPT_BUSY, &svsk->sk_xprt.xpt_flags));
   414			set_bit(XPT_DATA, &svsk->sk_xprt.xpt_flags);
   415			svc_xprt_enqueue(&svsk->sk_xprt);
   416		}
 > 417		if (wq_has_sleeper(wq))
   418			wake_up_interruptible(wq);
   419	}
   420	
   421	/*
   422	 * INET callback when space is newly available on the socket.
   423	 */
   424	static void svc_write_space(struct sock *sk)
   425	{

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation

--BXVAT5kNtrzKuDFl
Content-Type: application/octet-stream
Content-Disposition: attachment; filename=".config.gz"
Content-Transfer-Encoding: base64

H4sICK8SF1YAAy5jb25maWcAlFxbc9w2sn7Pr5hyzsPug2NJdhRvndIDhgRnsEMSCAGOZvTC
UqRxooouORopa//70w3wAoBNypuHlAfduDX68nUD1I8//Lhgry9PD9cvdzfX9/ffFr8fHg/P
1y+H28WXu/vD/y5SuSilWfBUmJ+AOb97fP364evn8+b80+LTTx9/Onn/fPNpsTk8Px7uF8nT
45e731+h/93T4w8//pDIMhMrYF0Kc/Gt+7mzvYPfww9RalPViRGybFKeyJRXA1HxKmv4lpdG
A6PheVOXiaz4wCFro2rTZLIqmLl4d7j/cv7pPSz3/fmndx0Pq5I1jJ25nxfvrp9v/sAtfbix
yz+222tuD19cS98zl8km5arRtVKy8rakDUs2pmIJH9PWbMubnBleJnsjic5FUQ8/Ss7TJi1Y
UzCFwxoe0fTKknNersx6oK14ySuRNEIzpI8Jy3pFNjYVh8UJWKOSKNNKj9nWl1ys1t6SrQgL
tnebU0mTpclArS41L5pdsl6xNG1YvpKVMOtiPG7CcrGsYI9wHDnbR+OvmW4SVdsF7igaS9Yg
WVGC0MUVjySuuakVaowdg1WcRYLsSLxYwq9MVNo0ybouNxN8iq04zeZWJJa8KplVXCW1Fsuc
Ryy61oqX6RT5kpWmWdcwiyrgnNesIjms8FhuOU2+HFiuJEgCzv7jmdetBsO1nUdrsVqoG6mM
KEB8KVgUyFKUqynOlKO6oBhYDpYQG3SjCxXLxOlNk2Q5W+mLd++/oJN5f7z++3D7/vn2bhE2
HOOG269Rw03c8Dn6/a/o9+lJ3HD6jt5drSq55J7yZ2LXcFble/jdFNxTX7UyDI4PbHDLc33x
qWvvfQoopQbv8+H+7rcPD0+3r/eH44f/qUtWcFRmzjT/8FPkWkT1a3MpK0+rlrXIUzgb3vCd
m087twGO9cfFyvrp+8Xx8PL61+Bq4QBNw8stbA5XUYDf/XjWEZMKFK9JZKEEKN+7dzBMR3Ft
jeHaLO6Oi8enFxzZ83ss34JrAOXGfkQzaJqRkQluwCDAR6+uhKIpS6Cc0aT8yndiPmV3NdVj
Yv78CoNNv1dvVf5WY7pd2xwDrnCOvrua7y0JQQcrHrSK1Tl4BqkNqtDFu388Pj0e/ukdn97r
rVAJOR84G1Dk4tea15yY0ekEqLes9g0zEMc8T5GtWZn6fqrWHDy2L03rYIhx7QFYC7McsELQ
lbzTXtD2xfH1t+O348vhYdDePoiBMVhzJOIbkPRaXo4p6FrBeyGHByeAPZUFEyXVBk4bXCks
ck9SrcMLKQAsEnCVZg3xJA18pVas0jycPUHAoGUNfcB3m2Sdyti7+iwpM4zuvIVAmWKczBmG
n32SE6KxvmI7SDoOtjieA0+zxGZZSZYmMNE8WwESYum/a5KvkOhRUwdf7JGbu4fD85E6dSOS
TQOxC47VG6qUzfoKHVMhS1/hoBEispCpSAi1c72EU9q+j2vN6jwnTcSSKR2G4AUOW1vJWlxk
dwJg4IO5Pv65eIEtLa4fbxfHl+uX4+L65ubp9fHl7vH3YW9bURkHQJJE1qVxKtPPbLcekol1
EIOgpP2BUDft+dMD9XxLnaJlJRyMHlgNyWSY3iD01D7Vbr1K6oUmTrDiENkSD8bCDwhbcFA+
SHYc4TTISWwZ+8MS8nzQgD5UAUjdmQbR9iawwJjijDVcU8ZKSBEuzj+NGyGcs+zi9HxYoKOB
wU0pSLdvO2U008b5CJC2kBcn4aClTJZ4oKT0O9GB1+TNUkrKu1ps0CxFeebBMLFpMxpfLzZd
GIBDJyM7DpaBSxWZuTj9xW9HjSvYzqf3UMK69xpyNQdMAIinzjlMgceyhqRlyXJWJmOIaXHt
Eh0kDFOXmPoAsm2yvNaTuBVyldOzz97prypZK+1v3jU5N06KumXI4BiveDXHokSq5+gp34qE
0xwKoqaZ7Q0sk8YIoTmZXX2bB8yuHvLmObo9PwocrHmysWkhukHjMu3BbQIYgagHvoQc2ykF
wkI7Cc2z1xkmFqriCcQKag1VmBku8w0K2wLdKvXrBvCbFTCaC5keTK3SDoIONpaO8d1AarGn
zz0B5iyznCZ9ooSa9DkXeqgodwVXVMJmZOqnIhjTTQ5eIeHKJpiRv2mzcK02VaMgm8fyhycy
lQ0/YqdcALQUoKCVv2ENGlWAd25aMDFzdgRHh2WhWe8LbxtdSxPgE3CQpQnyHs89jDc1hDJI
o0YxvQOuNUQCb9NK+jNqsSpZnnnaYwO8beiHtygnozQS5NmMUJZeBykiE14ywtKtgLW2fQIX
hZK38J6cSSWi+bUW1cYTIkyzZFUl/LqYLWGkPI01YiiXddilLdSpw/OXp+eH68ebw4L/fXgE
9MIAxySIXwClDZE9HKJfdlsKQCLsoNkWtiJAQZfC9W4sKnEgatCgvF7OeWdIShnEhWpD61/O
lsSMOGg4iaR9o53dFXYqI9ikkhteWGTeQKYrMpHYEg91WJXMRB4EN2um1n/6VsB3HBBy5Eyl
606laPYsO7pX6mxbmrIQToG9OeJixr/rQkHysOR5IBsAeYDWN3wPhszzbCL9B3fVjzdormsi
pWZXbKu+YOpgbBgHEsScU7vjGQhWoJ7UZdgjCv+obQh+AOAClr1kXmFhU3ETb9sOLkDUCCmA
GJdlR3JyrVMj+YIghoEkpsko12yXbglrKTcREau5kHhX8aDYjpBWrGpZEymbhhPFRKdNRglI
BZF1D0EaU0PrzG1hPZql4ivwx2XqStit0BumBLVKJeKc2NLWl2CknDmkENEKsYOzHMjazhgx
oReEdlNXJWBjA1bmK3Psy1DhKSoxcOehqnZ7aV3EpSgrrcA8fDFaFjQwzTIOaa3CqnY8Qquw
Tr62QBpxtP1cwWyClso6KAkPi9M8QVfYgLGbkVwATditoXLzBCCah4gJ0uBcYyIIviQLRCNG
kHOdszdGA2FIMpl1q55M4ix5OuEN7Hqc807YXYnFGd5W14nzcUeNlXeIZKSCaJmZJoVleVC0
kGmdg9WjTwLnaZEqsUS+AzeIoA4rVyikkYpp1x2sUBbji4xEqn1r45AV9ZF8lcjt+9+uj4fb
xZ8uqP/1/PTl7t6VH/qTQba2rEgcRr8Ay9YFFAdsQm/eeR3nldYcxUmhZwOIEo7Wd5EWqGmE
CBenkexiYbqUHeyEBVisJdYlEohZgd6WoTXRTVdJX6SewLIdp6A0tiWiDVZBRIoIoywjpu+o
GkKnRbaWkEN4qD0F1HhhWLBkLcoALSwx1aYwCAtriEyXp8OvurRXPLBPBeETpTmdrzMjMXBU
hVdpdfd6tjPIUl6WvjfCwaZofei2VejUstnq5sAyTYk7V5d011F7m9Z3BqOen24Ox+PT8+Ll
21+ubvflcP3y+nzw8G53h+YdgR8x8KYr4wwCFXfpr38oSNydQZCkgDASC2VrxOFw4AZ5meI9
I5HjIMMWVkAqLRJXMk8zodeTDO6aPFeaRmrIwophcqKQ0XIKqbOmWIqLB6+61LbNgHhXBQBd
MnAeeAHW3jJTkWEP4RoyJYgeq5r7ZWUQG8OY4Iuma5uZu2fptYqWAafg/AZSl24Zw+XNtmhz
n4weq59yphgbs0Z1s1Laqp9LJwdfsvlMey6lKXUrML84CwZAiyaH6Iv2iqrEdkpUYU2ivXN3
1cBznyU/naa1TzUAhmEsC9UfDVtB4HG1Jl0XIVmdgzwiAzQ6untuIVT0pgQvIbZhSyFKUdSF
hRYZAON871WCkcGebWLyQgfwpq2YI6zhOU+owIdDgvN0e/UwWNsMNjZuTCCGstpHdIqbOJVL
LdgdDguSVbC7oqCLx4AvgWM/5ujM8VLI4NGAZWzWPFdhCahgu8jvdOppX0NoFFxk5LqgK5iO
WlBqCnGRF8pY7BkK3LVvZQ72Axuijc1xzYxrzS/UAYvBMZWJlEhIorHilQQ4Y+t0y0pueGlt
E7HcyPUXE/XfbfH5fMKuTs9HD6O4VpnYxarc3eo1vKhzW4DwTvDzBnxyd2wiAV0FSyWaet0c
DrkngX5SXqSnQ5hxXiALslu7b7CVh8DuVC3SocnGb7XeA6ZI06ox8XMw9xwL08uQPNSZ6/Ci
PcArNqKCr2x4yYgXNz25vUWP6dacu+tvgGKjBLAlRbfRbk8gm2aDjrbBZMY7kTznK1CyNtTh
7W3NL06+3h6ub0+8/3qjnFvFsIWClTWjKHHK3S2Za+5rvyerHaDNglOkLfwPiyWxOAcOW+pr
3IJUY+SKm3VUPo5Hm0oDsZYZBr+gubEhJ8jInLIIMIYqJbq3WwcM0VtJmMa0kRV0OZN2eErr
3SBraVTu1zrC9naXgTn1DCBduaXGxuTTPobqcZ8v4hxQkjJ269bHfgq27Y6kY0PQZsjdL/GE
wr23Ta6kmkwUMAeiN6RYVZG/8dfS5dMU34zJdyi7QVEMSaEDTgB/6sC5bnRBrLZ7FmO11b1F
SKuLTyf/8i5wqdSf2njOWWnRixejwysg+DkGmjEt00F/++hQX/ziHQ9ZR7hSUnpmfbWsPe95
pV1tfWjpXp/BvlVQ8uhYbVl3XC+0b9m6YuhU2gdS5VUVFrPs3ZoHSGZYhswAC5OW0pV4JtMP
C/yaJeQSWBSvajWhni4eA4jE57Ty0kNuhalC7AK/G81gSeKKzDQssmRxMAAoqkG6+KYYdSGo
QFgGV6GZ3IiOPB2RhwFQJTl4Jmjo5Ep/lP+8ak5PTgL/dtWc/XxC1+Ovmo8nkyQY54Sc4eLU
i1EWxK0rfLEyyM3eZUQ/m/aawnvxhq329mQfl1gGA6uYXtv6LOU1wZUIhG2g2ZAFnnw9bQPo
cNvKEddZw5jrb0u10P8siL+dRwef61WtIFJgilb45EDgLhH0qfTOitQWXWBAqgQH4R7lkqdm
fKnono6LLTguM3rB27rgqWhF87jA1JdEnv5zeF48XD9e/354ODy+2KIIS5RYPP2FT/i9wkj7
dtmLVu1j5qHKMmhtS9IboWBTJYn8wRfmnHuOqGtpKy4Dyi/sIwJLowe6ZBse1X781vYdrKfM
AXWV+N2imaeLC5e/Ar67BHQ33F21IYnCqol/oYK/GoSIyb6xKqtHhT+HPe3jaVeExi7Kf2Rv
W9rrSbcQ+7WAHn9f4DhbYQ8ezY4IEDbTrv/EssG0tg3oTFWJlPtP18ORwMLbGDg1DosXv2QG
0PE+bq2NCcGLbd7C7NSLWUvM2LhDSldILc3m/xWHEwwuGDuJuFRfBC9fQ+JoNqEKMTVb6F7G
B+CmY6tVBSph5ORBIMwu/ATA7aXWRoKianAgWfyuO+YgNdltwL6ncerYH/c0+7RduG0lqHHk
0zUbe4u4yuEWKiHXFyUfi7cToXNkbwlayDaTDwfRS7pm5/qGj49ICRaQ6cgZNgBFNb4OXkNy
cgngr5FlTi12sGimeHyV2be315zhFEigayFYrZeQ861o9KQzcTG8X11kz4f/ez083nxbHG+u
74Mnq51xhPUqay4ruSVe5PZkdEBTT+AcRwfacSC8m8XPtMrpd3NEJ/RUmm3/iy5Yd7TP1L6/
i4TEDBZGPomj+IGGuNR+RjUhNm+3Uxzd1gaoH9D7fZCy/95lE8vtleJLrBSL2+e7v4P3QAOU
Vd3HaQHMVYmtI+NU0/cNrQueZQIEwVMIbq5KWomSfmVn5/zkSuhFaJt2W8c/rp8Ptx6cmZgk
F8tRXxSJuL0/hKYRhoWuxco1hxTUd2oBseBl6P4xwuMHZnrgS2St8glH5KSObKOFFoeHp+dv
i78smjte/w0nF2xV/ALon+66fD12wln8A7z24vBy89M/vfdfieef0KtD7sqT8CIGWovC/Zh4
w+a+p9Bxr6Rcnp3k3D1xo70aACsEM8uaghU4BlAmC4d2ZXrCXyZzQQyplfvMrcPQiEEnebWp
qbdoa9N+DxIwC7mdHEhV08tVTIupV4Ld2xUH6+Ec/3g6vixunh5fnp/u70EtRpbcfigaPvXB
q8ByGS4YS2106tiGW5yOfAELQ6eCAm3W9vY6W3Yr5l8PN68v17/dH+xnxwv7OPHluPiw4A+v
99dRLrIUZVYYfDThpWuuTSeVUIESuKAqazoytd0Koemvp7C6Gyelg12xj2dDRX5inzv/c0z3
pDH+ba8X6vNPLj0tgqKtfZsXd3NXVVt7flIFaU9ib+6HlpL3nwyWh5f/PD3/iX59lN5BXNnw
4MYVf4O1My+lrEux80WLvy0LtfXMf4KMv+yHwEG8wEaMahPdIZNZQlTMRbIfdXP1RirXdz3x
YaM2ItGBJFCawc2Ca5oZTTj5DUeu3Itp/DyK1gmFz30xzKeNvTuidgdM7l4pyRnkU/4zdtWo
UsW/m3SdjBtthSJaHLZXrCIv7mCzQoUvVFwbJB6gTkW9m+zVmLosg1uJPRaT5UbwSMJ1OmbG
9kzWo4ZhYG8QlHjD1gMIsg1cq+DhgVtWXBsL6VYT3PgTJzta6dAPb2Ha+jEm0/HcHs9oginO
JecTOoN8eUV5SkuyVhjKwySqaw6HQflPmCT2gX+uegUd9t2TlsKrNPetSb30b0b79kuuzaWU
1EBr42vs0KyxfTzDer/MGdG+hZRYE+1YKLMXVGNSHmi4N1JJCbin77lVunFHkeeAPgUFQHqe
NKG3laSe++wyhk6aXiGx/cIX+pEK0jF08p5lgjln6RUtiI7crf3i3c3rb3c370KJFOnP9CM5
obbnoS/anrcOEG8is4ku7acw6KqblKWhJZ434ZG4NnAFk1Z0TjgFf7ZCqHPPkrBJ5MFFjxvl
bddx3vmO0foI9zGz3jlHMsGIfiQW1EC1Mm8/MBrdgdoda/KDbUvq9+Q3QniIWmwIVPj03FYv
/ciE49dLfMwYNxd2ZaPVuOZ4yInYCvxKFLpottSnWyAJ/BMKeGtSsGoTxhtlVBtus31AsV3U
em9LUgAcivBWDTjih9d9U/wafiB4LtZlYk/PBwRggG5fAI3HfyjHD8jtCLCIiv5iYuCBf4Fv
2lALaEn2I985un08ORzvmCH3P1kvM/QNpb3T8zpl7nvR6Etdn7mJDsQnDcc1iMGn420xKQef
yVWyJ8dwXw6QWhXwoQ5M5QojRqssby3MZmY63Lqx36JICBt+1PApzuaCqTuSTszUpB0LgIBc
GB4O3a+IYY2ITRAzo+KJe9r649nHt7YrqmRi5OHPCtB0UDh7CVzqCQZdFmqCpNTMsjUjP2wI
ecTU0IaQiOmsY1JPeo55jaLNsSFfGMKwJQuFB79tCcmHcm3zhIINJEpHkEpoBzY7KYRt8Vlj
WyxIbDNUZ8irXSmJ8D2QXcAid/tI7uPQMOq56yOS9ao7W1M4Lm6eHn67ezzcLtq/xjMkvn5X
56SI9eyMVYgZsh7S7G7Ol+vn3w8vU1MZVq24GV690sN2XFTcGnMNSyQ0LORrfe4bsux7kKc0
0FMdqBnBsc7foI8C9ogF65fu1mh2pJynbzDI1TzDrAzLiSsOaqASv6KeSMXHzNmbCyuzyWjt
Mck4OhNMWO0IXtiTTDMWOnDBQG8w2A8iZ1k6BPCG4kICUryBiAJmQMHaVNYhBZb5cP1y88fh
SOMu6wYM/t2iNK3MXpGhY8ztPrKfGy8Z/RmEGd681mZS01segFtBqZDkKcvl3nD9xkhl6QrI
Uwfg8eFbirctYOgQu5m3+K32fqeUVD27ryj6EQx8aw/ljX2je/u+FfGkfGOsqeyVYF0zvR6J
e4bdveGf2+86n9UWlzvPjiAU5LSrKXPueLbz+pafmbgKOWKxf97yeyX1XyllwehSP8n6dohs
OW36Gjy7IbjKzKZjc7KROpsdIvqyjuDoK+YzLBuDnm12Ib/W0rDZUeaDSMvDWV68cdYQY6KP
See4p9IfglPaO425Tbo77HmL7e8SvnNWvKxevbHl74tkLa/wX+oTDPXHM78+02LR4Dd+znNx
9vN51LoUCFAaEdbW/5+yJ1tuHMnxV/S0MfNQ0bolT0Q/pJKklGVeZlKH+4Whcbm3HeM6wnZN
7+zXL5BJUokkUup96C4LAPM+ACQODxfaL5TOV3NRIjzK+GpaTPCWoGRhZdqALBDdcUiYx7ca
DiPgD7BFwKdtCd4zjEtxo3CgyJkJc8u/UrhKQoYtLSFGIsU/+Fa4B7X52elxCcyPg2iAIGjh
3GsMCmZjOsKxP/p4O397//H97QO90T++P31/Hb1+P38Z/fP8ev72hE+P7z9/IN55iDbFWaHU
Phq4fehRIK+G+tnTiPD96pL9FRqxC42Yo4bpRD7T9XfgKVG4fPO7VlXeugfYsQq8CwIulf6k
HIegpBgWWhx4NbspdGPK8L5AaLgh0c6vVQ8hrrhlQflDx3CbcdG78NDAIu7X0dr55vzjx+vL
k9GOjv54fv1hvvTanrD3QNuERNaXyfnHFc3rRbsQxUkljJJ5HlAFXUEZXzD/mR4LRZdQ/zNU
loqqHMAGhFX8GR3DBnCjfLFAVz+C4ExoEBIrge5+QBHUIxltGoZmUEMdjquC9DBDPRuCfcWg
O1NAosqg5sYSwGC0epuvA0SrfB8i0B9ua14A22n+9/L/O9HL8ERTVDuNy8DsLMmct1O5HOjk
BiUMJ4y8Ti3dwXPPX4NopVT6Quai4r1azgPT4pDhYLAz49CgJB1owC6lJ7aDwv7sYugZf8Q4
lNkuUDo3/y66ZirvVU7hWv0XHfqlndgQ1lFO+k1q1yMFV+LITJGnRzJLOIrlt+ePv7CIgTA3
+iDYpGKD9kcF3SFG8qVWDQjqTAZsbQAYSami9/BzVFtUg2TTK/ZyLt1s2C+sqY08tzs//csL
UdN9HPKv61rv+eAigyNrKq4aiKVzhhyBTbTZNsXmswxIGpame0I3li2olJT44s2ZU4fI9U5M
3DUZJAyEWzL0Xv2O2Y2P9aurAmFKay88eAsWtaN5hh+NTF39fQfBmBRKkvD+gElFToYZYVlZ
sL7agNpU0+V6Tgu3MJhKf0O2KgLn19DF0kAPM7f7BqQ4vsBg4trhX7S7drbkPs4qcsttKhWx
jqM2OphRgFNRuQUQOysANbtjxhoKdvhaYG0yGxRmMFwtBhEHMXCfqdQd2APMWrMeTycPl+5e
YM32UJUccZMRhD2ALiW0B5K193BmKJXkB5FTT/RUPLVRRtjVI1LyPIy2j6Is0xgRvF34lNu1
qSid0BflriCS1zItjqUgCrwW1OS7gAwcxzGOz4JltMx5tLsYATz8fP75DIffL9ryw8TtoqVu
5ObBU0gY8K7mDIx7bKIl9xXssStfmdDUX32oUWU90OWkjZomGgLRhpepVycPV+qt44d0WG+9
SYbAbUX9cDt4pMO6OUMA/8bZsL1RVTE9fmhHYlCN3BX3vHjdUTxc7ak0sRwGFSYPYcywzbtd
wrWtVIGnCYtFZ9D2ppev5/f3l99bgYouOUnj0bYgKxgEikd8LVUeuSF2O4Q5Aua0YwhPjkPa
PTGNtgDjKDOEDu15TGX6UPLQpT9ipg2wm4OTiQTXnmjssJQJ07UUPXcoPM6ox+4F1sYAvGRl
cVDkinXg5g2Hq4AOoQPP4GhkP6CRSty6RW6itpBBiTtGXgdMV7sxELzJQotVOXN0JCoh5uCR
5E64KMeIobrAPDOXMjZwsAkM+XAg93QPbTYpx4Y4BJErqDvwnFhmOogsaPLtlhpgYYsyzg/6
qHBNXK5dq6DW3qAbO5BA1JQOTS2CszL1rLAR0mx1QWnM5vSU0wYOMmbI+HCnK2/qTC/gBr6A
K9cFoUpMZgnXqvrEhuXHwvDc5f0uLjStjXxgeVWYn0A/NjTC9+bB/VEmzWflrXrctK1jOHWP
GH08v38MbubyvsYApN72qFuhJMTRVRi9sciVFc/6T3ciA3mf9YyRwk11AavKkx4RtJHcpY6Y
7bE/8kU+ip7//fL0PIp6zx9SygFJ2KEHpE49rIPDqf/qAqRIJarw0OSULi7EpnHEKX5McytJ
2S1T9WcRCEhh6mrsJz7oEj3RK67FBlyUEJc110ZCytWKNKYfXl1CmRgu/ffzk2tRZMqU5XQx
OQ36ViTBzCx2aDGihA3BGDCBrSI+6dSGDTuQwP6oStfxvoX0Ov2L5Hi6Z2OrJmrTVG2s1p74
qDCPGfuCdVSZm63P/Gw7ZvKl/bq+nBT3yt209rdZMAOgyss90fW0cBuLmHeaxy14N3B3uStN
nKHAudNSXAlKL1QglUZc7nw30q7QhFwq8BMO8K2qBXfgIjaXyv8gRy/Dkl/FHX4vAq9jSLCj
W6A98s5vo+Tl+RVD/3/9+vNbp3P/G3zx99EXc4C4FmxQjlZkjyEoqw6hnmDyHNeF9AJr1JRo
nns49NKvID+ViAr2Tc+SY5UvsEhO6jv6bj42FFh/LVgllX9aXtLsvTy14FEx9CPe2/wG1vqC
Y2DiQ52V1DS5g8HlsA/po2o0w0x5JVFZ2UoTVWUm0IDJB3TpX3I0IZRdprQnVXkbDvpCjuHg
RE/hZE7py7Ex1PsokdfQTSLSdGPDXF9UQyletyi2X3WobM+/Sh0C2Xj6A7IKJZ151E4cWZbE
CXfKHbUMFbr+espHOHdIFC37m67pFpZlbi6QjtBNE4dunCbdZ4S5lhIa/yKJc2mjaHErwYTj
NqHK2kX8+/nnq3X8ffnvn99/vo++Wufw89vzefT+8r/P/3BuKqwX09Bk1kZsPEBojFllkV4w
tB4NY23imG4D8RVIUSpw0RIiwfkhmnhqvXvs+uK9Pjik4J98EO7evM8NnQA6Jrgmkg/8NJkw
A6SoCTFRQDFxiPNk5aKs5aSJxmdi9H2aBAswKS9M9Cqq6hgSYgj4QEgRJO4CTXXNIiUViYUH
vhXVqv/ODO3+HY67zFpLm9wwNb7sW1fsUXr+j8dRmiqKkt+UiDRJVtAdCUPBCu35xdrkciL7
pSqyX5LX8/sfo6c/Xn4MvdZNPxNFB/1zHMWy0/o7cNjDzeAxoC3BiGuFiTUXGhPcpxsB0tZR
RfWucQKpM9jpVezcn1gPH4jtzDRi+VcpZ5yHVNd55XXGwKZ+Iw2Uf0Hs0etrtWDICtQ3fPUx
Iov0cM8hBu49TnLv0CC/pt6OE5kHKDK/YLHRnoWZjZtx/vHDiXKCUQfssjs/YaR4f33j8z50
pwu8GFo2GGwO7wavDS24NRK4/i3s1kEXsmi1PFUFJ/ohXsndiel5rDfTKhCz0PTpfj2e+8US
Ci03U4zTqTmDGCQAlvnj+dWvOJ3Px1s+2KFprolmcsCsIxzTZMYC+Ho7uWYi9PPr75/wXjsb
Rw6gaI9+55CgA57JxWISKBzTJJhO0bXTg5tjhekXbdBCulcuNIX7RmW24HRRrse0SK3r6SL1
h0en0LXgIhisafjPh2FkwrqoMSgi5gwxgU8pNq5M4g3ETqbtjRm9vP/rU/Htk8RlPmB53V4W
cju7VLix1tnAome/TuZDaH2JVWvWBGYUiqX0u93BG82GA+9Igp9BheGFmrUeiEEKU0wUY4ap
oEagpyvMeYqW/chbX2lso6LBbWvgwD4WwU1jmqL0fZHLnfvkyiDtHcZ47V+jjUyqkvFtUkxy
6x/8PuVmU5v9cGNkYcmEbwtDIkXCRlzu8Pg/K2D6GE6/0yN3SqvFmHuDM3xJHnOLqgV3gUmv
d7AjbsWC6zUND4YOMT3hqG9xL7cce1rCVI3+y/47HZUy6zh2lvcxZHR4Hkwsa4b9AUEaj9fB
0WPBJvPC3HjfAp8ausz2G4/XAkBzTE0+Ir0rQOj0Dh5DsIk3rW51OvZxmFCXiE4dYpvuY7e2
gjjUAP+6z1UdylCX9Ev+P0MYjWIFcCJ9wW/yDAy/s8gV2ZB19gowYZy8QlCIoA3GMIqpYMMV
euE9S4kMsm/r24I4BYAbI8YEiDGCcQadBUGsd38sWxtcN9BPXrbBSC0L9PL+NBShgFsC6RkD
p+pZehhPyd4R0WK6ODVRyYZ3BNk+ezRj477ub7JGaJ7HKHciD2Um0VuMliX5Q6VWSWbUCZyZ
l9R3s6mejyeX9QRydFpozNyDwe9Q7HfHegcyecrrBEUZ6bv1eCrSgE5Wp9O78ZhzjbaoqcMS
dENbA2axYBCb3WRleIjLKDiYFR9juCMxTb0b83zXLpPL2YITCyI9Wa4d44xaAZcjV4vJ1G3H
odU12Vjy3PNaVo7XjrWS/d0qRS6aagsNKTP3etO+MTWJFnfzNd9juA5qmEPgCspZY2H8yHh8
1kXnMPX3lo1EFpfIDV+s1PsPLKYR9ZRfjxf84hrexv29RpGJ03K94uxXWoK7mTw5hqI99HSa
kxgscrOajAdbxPSpfv6f8/tIfXv/ePv51eR/bSMlXgz4X4HPHn2B8+HlB/7Jnw7t5JoyBZos
nkdJuRWj31/evv4JBY6+fP/zm/EAsJ7X7oAKNPkSKPGVfPykdsEdMkZ1rb6B0DHK4CpGJZBl
YYlRoY23rmTjxQ60woRUSeBDRLHfXGrcYWy9/ksPKc9vXzykqW1YE/ASxwfu9IrljlijyFNq
kujx6xiQVqGLofyCJHHMsaI2SWHURwHVUqtOrBo4aiASY8xQ80aARRn/JmWQ+ZVICclee4Hz
7GDGcTyazO7mo78lL2/PR/jv79yOTFQV40sUX3aLBF5HsxozIWGNFBh03uib6Qt6qxgemMYU
gdrgQs8DJhJo59hWwbwjwsq4bDlGkj3sChCvZFUAGxPnkTIvqv4J0ol2H28v//z5AbtY//ny
8fTHSLw9/fHy8fyESe6G/GRnJ5gd1ut4eTp51jwX1Hg5DqHgqwYjUDRluQ/RTGaTIGo6a5aT
ZrnwX9YdkhUnw1MauNWGNWxk1ujEudVMnhrC6hk+j1jJHGCMgTeeyYJ4LR7gqoj5W7V+LHf8
deiUJyJR1jENSW1BJqVBolguxi1gG9N80XENwxoK2Nd9BAesH0o9zhVvytiexrW+1ZKMJsbI
ovVkMsHB5dk73BesLtIts6JDU0m0POLbiYimKuQ9SqY3isUJL8gmFnU6DezSdBJEBPY8YEJj
GZoZKaI4pyGcoT8h0862HzZyDl2RmznPhcCqRxk1YKmUn/jey9CqqNW2yHnfHiyM3xI2K0FA
dKH9wvEg3co57a/zjRQHtScjUe/2Ob5BQheakn+bd0kOt0k2AcVlqh72gYi2bgt3caoVMW1r
QU3NL7EezQ90j+Zn/IJm3f/cliktSbuCh4E8ARMSiHQS8T6tTj0RPemMpdQ+vbVbozaU2aWi
dMqzDRqmyg8bPywPA/PGJF7tJp7ebHv8m9HHuYNkIE1eavTwgYMYXyAbf48xJZ1ojmw9Ddic
HE6sc4FT1K6kouqEtY9yPhhk+ov5TxDsyKDmp+vBtN2QH9Z/wS0XgIENpU5b7lhDsFsD/mSK
nY9vDIlaTxcnMruq9O3GetTn7EZpmagOMc16nR2yKDBh+j7w2K3vH2/cdBnUIvKCNDxLT/Mm
DqitERfkOgG7uIrVx5CGxG2TkhVdLfd6vZ7zNwWiFvwxZlFQLS/N3evfoNSTr3nn21MMdmEu
p+vPyxvrPnusiOUU/p6MA7OVxCLNb7BQuQCGiObhaEFskblez9bTG41cz+7G9Hyc3t8elfwA
Vw9xKjK50iOP8Rp+WNwryjjuipBlfxv1O863Xr7xnTBJyNk+P8Zo3JOoGyzwQ1psadjbh1TM
QH5gC31IgyzJQxqYT6jsFOeN9x3Tkr1I8aWItEWKFW916nyIwUzqmNxRaxBTA0F7EVUX/AlS
rSfLu1uV5bEWnl13h4vIQFbL8fxW09HUvGIL0yKDC5XYgmpzKt9cWTqOH/giVUozMml5Nx3P
QoJc/xVh1eHnXeA8B9TkLoBKbsy+zjQZvLhUchKqB2jvJpMAl4vI+a3NrmtznJGO1RnKMLeH
d+/lLy3LxywW/OmKUxgHNJ1oP58HDizFZYl2G/GYFyUw9KQDLayJjqYbzUMRiGXTlVLHu31N
jiELufEV/QKTxsCFJlJ++9cpa7LulHeg5yf8bKqdyvniEHvAFHGq5tRHTrFH9VtOI8BYSHNc
hBZWTxBKy5hEET9hcC2GrIDROWMTsJ0vd4+p6tNtZEqNAHLFgELAIZnXMARINixO1Ovx7IRI
x583M/YrjnbFMlUUGIH8Bocv/fQBL1RKl55qCpAKZEVBYQdVxxoTyO8e6dqqBIyGktpvPtm8
gb510jatCuTqFSq7bLtdcXu9smCO2ZVlute0oPYSoQOQm0jdIqVQkKIn45NjHAByHip+xpOJ
pJSWhfMbF5XAjSxXgcb1bBYtKlGnOPJKB0YYHTw2wg2MbaCFNCom94nZEEOvs/3J2L5WMecR
Zclkhq+6JL5S2xVgJu/uFpnj1lyWNC1kWTYbHQWivSM2wkzLNOI4gq2reeCbrHTDohkIusPS
KNsALojnPALoZ4VxYP9KaxZ+LkyCRWRT14H1yovPOt3JblPjq8Sn95cvz6O93nTqcvPN8/OX
5y/Gug0xnZ+T+HL+gTEmGMX60TtKDe74gpa5qIx/fX5/H23evp+//BMThl6ej+0L2jeTx8dt
xMd3KOa5LQERzIlzDDjhHLITahAD7wefVa33TchZRkfM48K3Hz8/gm8cAz8TAwg5MVlkkmBe
QnSHceRag0GnNOsp55Vnc4ff805+liQTdaVO99ZUojfJfcUB57yO2o+KvY7ZGjtMU2rBJnrx
yDTsQmCmT79OxtP5dZrHX1fLtV/f5+IRSIL1xAfiQdgBrU+SM08hEzX7wX38uClERRTSHawR
UblYrHnLWo+IY8UvJPX9hq/hAY7iwIO8QzOdLG/QpPdQw3WSWorlPGD86xKt55MbPU6zdSha
E6GZ3aCBrbyaLe5uEEl+Z14IymoyDagTOpo8PtYBq76eBh1sUdNxozpdF0dxFPwZe6Ha5zcn
BJj4kmccL22CvcurbHuSU32zInz6a2L+2rgQiRLEFF5OcTbtFTzsV4xxGQjCaEhMHCo2kKBF
F3u5s0fCZWM7QDRRK+OqVvRZ1aUQkV6t50umCkq1Wq9WfB0Gd+dYsgxwvjkKQ+GZpnCEFRyL
E+ruQ/B1htYHpzpU02Y/BTaOMxlyqeRjXevSqPD4elqCYDtavHWpC+KthpEf0I7iRhXzcB3R
Yy5g6nnkTmSl3ima7cIliGNWSiQkW5GKE19+yyGEFty2KCIVeNd1yID/g+nibk1S2D7/LTBP
cep6LVNMwQ/8UaAMclyPjQ0b2yxLwjs9unRwVE8ma9cWjmClXpBXAILM9GQyD+DMDx4HUvWJ
voGRL+9XE05RTk6LODfekYFhw2zX9eI0XvJ483eFBpb86Jq/jyoPtbBUJ6k4IYGMf1Qb4e/K
iYLWbCiiFDpkXUynYjJbrW+dCuZvBXzFLNA3EG11XIWHHwim4zFvpTakW92k0/Vkyj7xUyK4
MEMt0qf1ko2hRJpT6uVivKJxo+zl5qXvtPLQ+e2LMUFTvxQj5PKJgWvlWvgy5rgehfnZqPV4
PvWB8H/fcNciZL2eytUkZLGJJKVUpeZGzqJTtQH0sORK8HFsLLa15LhWMOBQrvW7goYXWOFX
D1xuCHQrstjPitjBmlwDQ81U3BOkc/a7ONtPxvc8K9gTJRkcY4OZln+c385PKMsOLJlBniYq
P459wTSmd+umrB99J+2y1pfEZCpHn2zeW9iaZHVFDICY2BlOMgzATeZKpBgG0Lp6B5Ls5sVv
ReixqdkGbKqNt3CjQ2Z30LMs5ryPAHGfxb1vgn5+ezm/Dg3H2qbHokofpZvxq0Wsp4sxC4QK
yio2nq6d7yVPR+zbXQSAdOEm4Calu+oiUpxrvu8i8soETdAX7yUXW8GkqSzuSfy5M0TxqY7z
KJC0m7QuvGc7kgTf7e8H6zv//u0T4gFiJsToVBi1TVsUXPez4IuGSxJ417Ak2OlUsUlxWwrK
NDpAZ5b8Uj8HVmyLRteK1tHnGpmWMj/xr249xWSp9CogErVE7UH5uRbbYOgMSnqL7ISawhOc
oTcp4ai9hq5K/vm9RSc6bdLyVh3wKz6JvDbRRmSRBgIiwBmJgZjymj8tbLSUbk458a/MFNyb
eZTSyAUGXgq0qDKe96FPra2tDf+YkFxBBq2dvdsCWte1NqyqHlSKybJCtR0xollUbL1CS4zh
ViRO6LndEe7ZPHKTafcgk5QBrkY8LL8OsZ35zQDhGU9eEAfFm1C7FMGgNU6zSjbe48E6nF0e
jGd3gcjQGFUT32dYZHYE5ohvQckqBmBRbE2Gs8ZL3FXLLbbVAyg9ACBvbaVpHqUAknsvEC4+
3x+KkPII6XLNCk9y21dKyLvqguXJijN6gtUgTRgIJ2DqwWca4exIH1nHAxDwhopqVx7HnhpF
ELoCkt0wlWGH8/9j7Eqa28aB9V/xceYwNVxEiTq8A8RFwogUaQJanAvL4ziJaxw75TjvTf79
6wY3AGwoUzWTRP01FmJtAL0ocAepMsOLHpLpWOCI9E5e0CWKNoMCtOiFuptVwoDvGy7nxDph
g9EIftwoqaNFxvSlnQlbcgM5A/0LGl2g/ffb6/MzinrzJ4Que+5HIX22GfGlw1v9gF+u4GW6
iuh72B5GdWgnzi351QSFw7y5A0tH6BMAa84vDlfvOAmUphC9oaiu4yCzr91tBvgypOWJHl4v
HXePALuWth6rzbjnnSVRUnNXB4ukJKyBcIr8/P7++PXmb/QJ0zt0+O0rDJrnnzePX/9+/Ihv
YH/2XH+ARIWeHn63c08zwbcHZXbkshBHtmp216x3RsJIc2WFXdjVjAUvZUYtSQh20sUwc7J/
4cTzAuIgQH92c+S+f9KbSeyq6M6aFA6VeCti1UsyvGU+lbOWrd6/QIZTEVrzmtn399TzENL4
VfK4sSgFbCX2SqWIvTmbs4U6S1en0uPEggvNL1is1XaQnmr9tFBzO/4NkjoXNuNBCYZref+9
99g/rFCE40VM2omSdLnaK7uRpjcbcCRS0iDXWnggWq7UkAwDMHBJxSPs0EZEBhCsY1gOvMAs
7aIU6kzSMFo12oe7w21Zt9tbombT1JsNQmzfwZa5b2j9OForp3GGX0qkySJbBhfdxBYEPb3U
nZivJHUt5pttbTowhZ9XPAQeZI0cZM4Pz0+dsSVRAnraR83yfScrWeX1YJFyUmLRWLa1urga
y/yMLuzu31/f5nurrKFGrw//EPWBj/CjOG5tuaWOw+XCszR/8PrsjAeN7lAPRw+sRKdwNF3i
dCSi8mcjhMHZx7PGrPn8P/7vqRcRphGgJ+qmpHo3ryjpZWJJRbDQzZ11xD+P1x99ieL5/n/1
KyXg7hYqtC7SDgcjXZQZRcZSvdgoVQeUd6/ebx7Fod/2mkkNX9cGRIbrNjh00zwTCK0+0SFY
7KlBqHOtlh79qavYCdjDYITizKOlm5Fpcxs49HfVwa4VRzjYaFpYOtVe32tUMzNdeqPbCZu2
YRKGzN30sWOtdCSm6mQwaD1g0AMqS7GhdqwBxVb41yPrgtDF8+zXIiff1WuYgRkflla07rHF
os02PHJsofHrJI+8ZRgals49Bqnitecyh+p4ijpeBfTjxJQN2uvQtx4DD3zwAiT+qzwg+oSL
1ZWv3LLjNmsLmQTrhfbM1o0ykBR1o1ONiH9KZjn90GBxJxLHYXPONl5hXOFnJ2r4DOY3+k8Q
zVOb1ItenWVGdzN5/w4yDnVD3PujAHnmuD02mm3wDAoJLF2F/oKkL3zj+cBAqGeHiaHEJ/u5
v40OiOhMEaIPeyYPrQZj8IT0uU/jWQfkTJo45Orie1SrSGguw6REhxb+r3Jd+D79+QAt6Uck
jWNFODHpgIgARLJaBmRx+xiNRq820t73fsmTs9KPdt14v1Z1DB8jyoSqIipRkw0iL/X1XkzF
kjQImHB/SQ3CFPWkRVlSpfJo37KSkpvGT175sRfl85GBQBzkWwqJwlUk5jXpn6ChB4mmyUWy
K9M5fVtEfixKEgg8EoAtk5HkYE7d8d3SD4lhxjcly0pq4ANSOwz2p3aNSIFhwPGIiaNt3nhc
xqt5Zf5KFkTdYRw2fkB5AEJfrUwPpT0CahshJg8AsFURwweBwHekCAKiWgpwlREsqeoqgChc
aZf4DmDpLYlCFOKvqdGuoOW1lRw51iuq09FxzjK8vhYrnsW1RU1xUJ6ZFLBeUbXeyWNAWTdN
s6oOyd2nzA554G/KpN+EyWU4uVDnmbFjymVIpSvK1bXhDXBI9HJJrdpAJQY8UGO6YFLo1WCy
4Jjcg4FOy3gTw/p6aWtq+Jdrsg7rKAgXDmBBTTwFkBWvk3gVOjR/dZ5FQAmWA8dBJt05kwsj
xuOIJxJmCyFCIbCi+hIAOJQQbYLA2iOlKxDV42hNb3116bhF69OKnaQGPpATUgy4dhk9bpdl
5q/Ca+2WwT628Ig+BiDwHcDyHHhUVUuRLFblFWQdkF+i0E24vj6AYU+NlpcL4bx0ll+5pFZT
WCD8IE5jP6Yw4XvUzqBUbQM6xSpeUYIyNFBMi278wAKPUqLXGS6XeZ4yWRHTTe7KhFqAZVn7
1MhVdHINBGTheHDRWa6u3WgImNTHXhSYpQd4GS/J+9yBQ/qB75NpZRyQVrEDwzkGYcxPqU9D
aO1TjmkNjsCdmLocMhjIda1DQMyG9aJx2KJOrMUqjkin8ybP8rCddytAy2C1y11IpqCrD0bj
2E1qPj8SEAL+3vPJ45Jag5n2pt8T7LPzQDadlw5U9DGLSvStbLjDV/7AOoSM3VYntAOs2zN3
6O9TKXLGmy6kxH9OokJ4iJoOM0El6G8UutAFVTNvA7MiVHv8949DTnwYUX/8kvM/fQv9DdPd
T30cWK9kgk5mlO2mbsuEngdVzknBSs18s0NElbSphDWxErml2m8yDGPOUHeV4cK7UBXTebB8
jPV3hWtQg6GmpthA9YXgm2JyDPj68vTw/UY8PT89vL7cbO4f/vn2fP9i+HOEdNQVGUbusLNT
xoMPr19vvn97fMDIlDdwwmXT/REm0m5aMQvlBw/97mp5UbjehxMgSJ8XCu9885FJe2iL5vpJ
SV/EdYz2a1BnZv3j+f3p04+XBxU0Y2Zs3WdQ5qmlSoeUzoJkVySmqweEoMRo7ZFnApVX9xCr
DxuN7LwA1nlcvlmRJ2VrLwocNjLIgDcIl8vFLr8n/zqhrU6P0I7Dmc0HWZNT3QiiZFtjwFJD
BijqBKMikB+CmEvZAsvr5lBRi27r+C98TofywPYXO3yAAVS5HAohzx7kC9rPPDaNhHOtdgRT
tOHoqH909gEfb0mzUkzTZPJo5qLdwg8CfU8xr4BGqnpetLqnSZMwcLjJULgUszdlk2Efe2Qk
EcQOkVzqsi0SBV+slpdh+TTyEmXkkWEfENvfxf4iMsR1trlE3txNrp6qN13oVkJZPj28vT4+
Pz68v/WrorIF5INV7txaVTH0egVmXd0X/AhLjJQShtEFTTGgOxz1K+pwvdB6EA0lfC8ypuBg
POHIQsGBv7Ibs6e7+uZc+MEqtHYxVaUyjMynHZVbeWUCnC5xRDk9Vqthwz9UB2YtkR2RWi8G
6NpCdi4jOE24PgxA/a69o8Vr8+JppDri93Rw6F9b9VR67RA0RjTUXUb0JPulcgI6rw2nqsBA
XBQDqo8eO51gcbT0CyYuFJyU3DTyEbWe2Fki41g/kmpQGoVr43pI+wq2Dkgp22LxqYzh4BGF
UUQWykWxDr2ILhVAODT4tDLaxIaTaUUfGS0mWqFOZ4pXDg+ZJlNE33ZoTDIJaSv1iQevRaN4
STULvqYuF2snpF/3mtA6CpyQfn2oQf0mbq/MJgdt5GbyxGu6bNgK6ZFhb5ITMt/kNCw/fsis
B58JvUULS9Qb+kUP9ZvUL7iG7efqt8OSG/nLkPx4bWUnsSCk+7Jb/QOyATSzOhqztgUbXVB7
ysQ0rm/TspilnCndC8oB//bt/tsX3FUJAxe2pQSb05bBgr/R3AJ1BBymIK4cxf/4mt0Vgl18
gaypKFeuaaO9V8GPtuSonaabISB1X4ohIOZXm55vZrEyEco36DVDPzKOtUIYY2m20DbpGIqT
rl0r5RgVC6X5x5eH14+PbzevbzdfHp+/PXZBzIx7EEyl1JPT0yryKelo4Eh2K083qh3oghf+
0ujGAcHgrBLW63VMr3WqxmnuBhs/oCeOAlnq0rdHmJUp9LATPlTHU8bcOF/79Nqr+n1L7xWI
uZSaERPs5IqGqZK6/LQpsDxvrzQVnEQjh2UXwseUPuyrlnJEr++/dBtcyTfhTXMU7S0MXSfP
7cVd9qZKdtQlYNeSyrwIetEcdDXrYtQOvu2/Pd//vKnvXx6fZyNbsaLqdO1wDacxdc4O2yJd
W3pLBHMBfNtFtKL2qnmWYpnFjHnEV6gLsLotbn3Pb3xx0R8ZVPM0PN1m9rdO54nN29PHz4+z
z8aJV8tDuCC9onal4/RpaxEv1SOwyiF/u//6ePP3j0+fUEfZNpjNDZ3NMWowLktEIbDQ9VFH
jVSbNiUPKwCocKanTIwbwLREYmbwf86LAoOnzoCkqu+gLmwG8BLm26bg0qoEYg26PALhuMBH
iBZD2dL1QneGZMkIkCUj4Co5B+mHbw99xIYrJVa1MDJNszxrMBCwab2P7LBxWeqzOlwyvF9w
+L/BdmfJXmn+05XBtP2eJayCJS/UJ9qR6+eD6ctgx0PcxGN3qFXEVcG6pOVpTHi3yZqAVu8E
2IoegBTYraDd6QVPDRghnSC0s0+5oAHoiAPX6K+eoKc/LBz2PygVbKmHIgBG/0V2r/up73SS
i4Upr8AutOEnJ8ZXjvUPsCKLvWhFb8pqrNkq1kah7h0bu0beubb7DnVBwuECbnNtv0WUO4fc
Iatg/nL6PhTw/V1DX1cAFrokGhwUVZVWlXMQnCQsx86vkbAZZO6hyxpHKB2cQc5ME9aUnAwl
j/XprgamPQm7OIMuPlSlcYZD+gbqTl494xqDnjPFLsukkRc7Vu3eX3sXkuqRVN+gdlu7PTVK
2onMuNK1RZLOdxkkJgUTorc7Nq6MASvkKYy8W8p1HcKwsKyDQPuUgRgGnp2VTKtgQRnkInja
boNFGLCFmRVlOKa+Y5ktw5JaAVWllThj5gRiSbhc51vTPkBxlyLy/H1OhqxDht0lDiPtJD01
qdVyM7yPj0lB8yvBCVPamPTzyshTw0Fy4bfnIqMkkYlPMJC2mKOctI5jUlyyeFYencFwk/CL
usK3uhTRtIq6bwMmJuoErpVzigJvVVCn4olpky59z8gAtjghGSkKwX4Cq6IpDfTQLjUd4RfV
ljo/i+p40HVE8WeL4assfxEGvUW/IAXjpjLngVRvUAnrhpuL05jfTEbZgeg6M3ACop4afk42
FrLJDlvSOzewNeys1/G4IwVjzG+aC93DAT513j+r6sweAZGfLWSm+9NStKQ5XghSa3gqQCrO
IPuL2LFx+QtXH5wVe9JtP4J4P9LcmUUnOw6/bOJd3Ri+T5EIzbStDg0XRp0maptTDhowZYb3
J7mZW1ZkiRnbXFE/7DPKsXHX9uWGN6mZDbBbLssU9W7WbmdWyIqaVCrru6a7vjFy4SqSkZWP
PPPDjpT/u+ocBMjU0lT7RKRIXOrrCs0O1amapam2HMePI5ESdJQTSLPeygu0qHJpkSv0xpFZ
Xa18IRFNiNHR9naF4OiLCghF1bgmSJ1JVtwdLrOU6KwkcaYqIGMQTngiZglhUWCUcIKgYLyr
pUHrYh+YxDrLumBEJllmcIqEGZ1ZYx1yQDffdmUax6WxGkPo0AxOKdRpQGVZskb+Vd3Z+ep0
9xSSfD48YDyLzOGlSOE7GIqUrNKBcHCTvc3z9MyoUWfrkfJNOJtXnJcVue0geuGHclbvD1lT
4dc60ny4S2E9tCdjp8/V7pTVuZFdjyRQcbzYV79mG4bySUFtGsoBBtdWFXTvV+0S3uL5uMj6
8/7UEiqYrS2BIlGZzO6YaHeJ4RHmaOrQdH6fgWaFhxzp9Zef358eYFcp7n/STjGwNJcX/ENV
K/ySZPxEciC6ZemWdO9yPBuXRfCzPe9Iy/FSN7SBH/ZDJpKSYr/t3LV3yjNl8qdI4T9e6TFV
TfU+dCJve0HSskSzzWH71fNTAVxJS30tsUjhW4x3i4HoVmUYOWytkXkWhcxLs006AMOWN0yw
A100wtKhij1x5fh3SMm5yHPeiNTOXUXTFvT6oPJ1vaRjz21cXg4RRf1ZkcK/HLU5QlX5sqkK
b1anSuz4ZuYwQ+MopbZIlyA6oAtjbVj1lHG4dSPh8evr20/x/vTwD6GNNSQ5HgTLM7SwPJYZ
ldQ9iLSXrj4z1bolfRExMv2l9uJDGzoeUkbGJlrTYcbOylG97oEwFd2RTTsajrQ2hz93w/zA
Y9WsNRTzJimXYWC85U900tejgtV5z7MKnh8CB/LSEXBM4XXC1lF4hUGpwFAORHs0ikYNe7tG
gOkGChORqCaQSYPIHo0j01nvQI4ddiB9X2SnCuQzTumZTl+vP/qO1GV4mZUHG6IfLIQXU8o0
imNSMZl1aRrE3pVm7hVUxcL1WqS43C/8CkZf9pG3sj5HFkm09i/z78EhE/17pbRBD262cU5D
WgW/+Pv56eWf3/zf1cbZbDc3/U3Cjxd8PSWOZze/TZLR7/akQAGx1CePfHv6/Hk+e2TDt1vj
HK2T28HZB4VVh0zsKmk3VI/uMtj4NhmTsxYbOMg7f5o1cTyiGkyD9jfhnePp2ztG/fh+8961
wtSuh8f3T08YGR6dd316+nzzGzbW+/3b58d3u1HHRmkYHI2yg/vTElZaTnRGPpYkGWoI84I7
bpOVFzfYWMjrhQzmD2yxFYaOF3DU1vQKFDSJc2N+SCdyamTSWj5QkKTWXurBrmRT1PEZzZaY
NORk7G4YjH32qgfEKaqfRhu1wuCUeoDTjYmiEGNSKk3KRwdDmeFylcOv5cLw6qTWC14xacWI
H/I8Y7aJpUDYU42bg57RJXntxFFV0MLHFkk6xztTi7Au3M6ldxo7FVQylBqJurLjJeUCTp+G
R+EjGQ4Y23UeV7576h7WjNPT2/vTKxnzvXsSp8WeHtyg0YK+mfX0LoCNTcU4TMYF4EQeHnD7
S9359ZlSd/3++un9Zvfz2+PbH6ebzz8eQfQh9HN2d3XW0AcJIdnWekDskUu8HG+922kGaPM5
a3Yp7dWCCTgHF6y2bmum3kS7+l/hoqzi2KX9gAzNRjres/r4Q1dKGFjmwTOmjyh5UbVNvueO
yKm7Wi1qTvDMmwzDD9FSo+DX6lezAxN4mXKNSbmQvNqQkMXdNZynGatZeo0F99k98jjOTqOt
dcpMd1zdIgNiQFHRLpaV9dfZcR2DFyOSNVdr1p9DNvJaLw1cO+Yw7VLVSMqafm/sl0pHWr4p
YfOgJMRRo0XVX5/kXY4V28N2yh2Wen3iW8f5Td0qt1vLHahVQuPQLOqFRbyyAsohS2i2+lQz
OmZrb8kE5zxeG0/84qgcBaMb4LDdHKUk7WaTXVOV2bi2aAtxh1RiajQbqNHcWtuSBsuYwV+q
bijWQ0VNfcOAQlXl6JZtdHgqvj29KAds1tVOooji9ccbZTGUFPvsJFUIbM3yW/1slbu2nxrn
pkhHzqlflXVRzR3uo3edWAqD9RcMpTw6/FQPHNKhMpb1PpRhYyAP9zBiN2aY7Dqh2rd3zF1a
zByOekenjmkDx/j3x29vrw+k0ajMlD4MzDjotfmxovn29ftnu8fQwOw30bkgrV5uEnQuOlm3
UXdXx8OFt6Jh1KUrmgCa0U9rtTfmTXZLN+cF55jr2qBqHIKwwxzjIGk9oxNMp41Dhac+Ux/C
m9veX9RAwBjTmIlhbNeFLwOBx3Wu7D2a87pKpONFq/OFBT9kUxUF+XqSl6amEKwsOdtndKA6
ROG4ceKGagRenzVcDm5KDfWIclwfZmMGb2DFj78777PTTO6fCO0ApvBTeYoN4kOJXiodQSN1
LjjTkg/JSdnu0RIGcTs+aGejyuhNr0zmN9H14xscpL/ev8Cq9PX15en99W1+Sd4wM77X7nhI
s2ZTFfN5yF4+vr0+fdSk8kPaVLrjsZ7Qbjhm0u8Dwyg9abEq8qe3r2pJnd3lZqmWH/xoDS/v
o4Yj5NXFWjQlP10rNUk3zDgicb2qKTqevxO5dtemSAnDCEwJBhrGaB9tlnMYdUXR+3qcJqNI
QFTjm1xiHAj6JnZbVVvYkCn98L4Vnh97F8f66S+B4rP2XGE0Q3U6NmYBOikS/AIQJV9kF1xC
c11NkUMVcJ/hejjYXBwqyXNjHKcdidzaFaIMjrQ82JhHT7k9VtI4nykCxjrG+5cpZgA9QTCo
QZ8CmuvAHabjHcfMhndA81K2J+NeryNR801llcjC+gKg9H7YtaF9lFUuFm1u9sYRH8ep+4EK
DpNw+Oz4u53k/uGLqRacC9XV84n7/fHHx9ebTzA8ZqMD97hW719F2PfaGlpjAhXtFUkpVKE1
2+LOeeCG9ZqCYPgXaaNHBtxnzUEvtZs6kxOBsjYbRhHokWrxXJiU5Nv5cQvDZqOX0pNUzTWp
Sf2VC6NVMMaUGvpQUZnp0mSWNHe1tPpxJMLCIsTs7Dvy/ZXnIqA7/LjhXR2+2hS048BQRKka
VFpbjwzFh4qgfrCuo4pqm9O7OWxtKgk9r5RwTL5ASFhk9v/f2JEsN47rfsXVp3d4MxXbSTo5
5KCFttXWFkqK41xU6bQrneqXpWyn3vTfD8BF4gImXTVTaQMgxQUEQQAE6WEqnc7g75uZ89uy
uUtIQC4J5KlL3mwC25kk72nHGSJx3akXm9KSfM5eESHjgvKcltZ8A5ayJi7FS0w1vhViuI1R
eLo/sTPWWClvxbhAupLXZlI+8btfms4dADRMwPo1j62LkAmrVzSfJdnCCjLA32ivIfO2COSG
RWtQ+NCBvbKOQojs6iTKqRkTWLE4vTJiWdOmB0SH1rtAhjNxSzTZJKezBak8lUntrGqAYGth
58a0q9nS3VIssqxCse9tlBLZYAiLB8V5L4kvViAjSnoxquoK6GBafURS5iRXCxwcHxy1LanS
iGaXSAvG8TRJzYLCXbpDKAAfahySAvi4A0Xb0AVK0z4NP7Q/4urL0+H14uLs8q/pF6PTOS6h
lIlN6ZRMFmaRfJ1bV7tt3FfKl2aRXJgJqxyMlW7AwdHXzxyiTxt/cR78+vnUHjQDMwti5uEW
Bx4Ocoj+pFvndGZdh4iOorWILufUfQ2b5OwkOLuXAceyTXT6Bw25+Eq5oJEkayrk0P4i2Iop
PvD26ReAKrCF5SK5bkYZU8wGTG0+0WCHFTR4ToNPafCZyzUaEZoejf8aKkhdebd6M6e7Yz5Z
a8HP7Javq+yi5zatgHU2HbqeQCWyg3I0ImF5GziijyRwUOk45SoaSHgVtZn5TPCA2fIsz7PE
b9IyYhLufRADDNcffC1L8Eni1P9YVnb2bTar+85lNo+o7fg6a6gYVKTo2sWFcV7OLesJ/Ayk
UVrv9i+7/01+3j/8enp5NN72FLpVxq8XebRsDMesKPW2f3o5/prcv/yY/HjeHR4nr2+Yhsk6
+OCbd8IMaYYMobaO51s4aN+wIeXZ+EKkuMGoyqZMugN1H7ZlhH5jyyGbvD6/wbnrr+PT824C
B7aHXwfRqgcJ3xsNM9xOmGkdX/OirX2lyCKHZ1rjSc2PSIuuaXvxFBtl6eJRIWu7mp2cXgwK
JmapA6FSwNmssPZwfKpCVBsFnnPsStCUMb1NEVek2iGEWbUprSvyotPW8Qy+wzAVMzbcMiwI
UlARMBAbj2YFpjOjlJXhaRLZyboSJgPTmmHCvcbgw1lK3ZVREganYEQ1Hlv5NQkcwiXkFFyd
/DO1K5cHCTu0bJLuvr8/Plp8LsZKPDPaWInmZC2IFQns/PGp4m8wQrRO2ORdHFTyxSPIqpEF
K3Lov1+7xhDl1fS0aOrtGnm2dkrfBO7AS6QMSwjWLE3asD5sUaXAwoaUwXQxzjHvS/kt5HpS
IyhnFuau/mQwRI/QDrPIqw3BjyY6VJPgSBy7EFOvQKJ5MlCwxSR/ffj1/ibFx+r+5dGMNYJj
RldDHS101jS/oEHaRxqm96rFa+KFSRhyyIWJ+5so74DHfUq8W2BSji0L06japubYYNP7FTor
26ih70DKsiAQqoqcSQvvtlgicTOounYENzBNqfcCmACqxxZNmFhQLp1cB6xMQ3IMP7pmrKYP
k9pNJmuW4WboHRwkxeQ/B+VGPPx38vx+3P2zg3/sjg9///23EWElv8Vb2AtadmtFGUnGg+/b
3kO12AZyp9mbjcSBLKk2dURemJKUWG2vhdSw+8JK8U/HwhbCrEy7ojT2/4M1rIoFW6ADunJm
1z2Whlb0Eb4kxvIFRgCRz3xjS2ABgZrDZHD5aK+0lBGDBXDyBZKQoFJABxsN/9+g56QhyuYZ
GaSkJFom8N4ML/16tLAkI9Lkey+c4YXkLMoH/uNJR25UYkoB6c4ygEBnqBlqKeYrTA0s/0ai
vQ3YGeZR9wBiE0e0G0lQoMPY5/mwpGdTE+9NCQLZddiQQe4qThYf/Oinu48emYImtZwBQn8Y
PkVxJAxpmWwxiGF0LOi7JXpX4hmITpETFxNZSClksKjMljvwqX9hBa+JCJS1rcC8LrpSamAf
Y5c8qld/RLOonWUlN1+lVi/0pIWR/SZrVxjg3LgfkugiqboS311KKp46JOjcEAyDlIIfvUpg
HfCtA0xUbbJqRyKIXGm9027ZlMQWthwFUNwtFuYYiXezBb0lJOEPyN1W5bHyRtaoSkjdjTCL
29+36tNuaLciRUikanF6FGSET3gA5CXs/YsRPuqnYuuUcOrIolhVTlnjjXpTgjKHsdMhxKD1
+UPD+phHJYwrCK8FPmJpiU0LJzy6IeejJIhKWOYo+FRJ8tnYgRjYT5MRHw0Oh1Qx3NFdy2fS
BROZtXUGnNLy6oXE2T5BXcLWBKzVR02UZgDVRWuS9SziG2hd7YnzUbEvsir0gXG19jGIwlUR
cXpVGWgzm51B8Gk7ZHNZ2RV4WBBuLj866P1FnPTb3eFomyvwDUHclkHdNdeSnKWmb0ABbbfe
fhePchk0k+CWF7ecMX3hTa8u3FFBze1N3MigjIsc56HOSpXp/HTQiOghwV6t2G3aFZT2JdC4
A5XLIaHAs1N6DfiWfLJToDl6mUT4rNV6UCyylInbl9P55amI/sYDIcXQXZaDDl8ljZ0pSMS4
6/d9Q5/P1+Yz9QgZdlKvJ7ByQtXokA2vTCdsSEQxOCI6KqYcy6iF9bZmW/ticIQZUoLHV3no
XKaW9xd/07YBqTGkDANsiCoxYlsppuIQ1xkClEU83yrzmOUPN+B9GpOJHEUkeIuc5GquvEoj
Ow7EhId5WNuJWgzo60DA8qqkGE3pwrfOAkqrDthO2v+cFmEgQd7Z7k8VdNhyRl7wEDMxiDJ/
U8XupwxN/XxYc8ZWWUlrY99ua9af3F6cjIdUF8fSqymNk9x2NaOxuJldzc0OKSx+jhxgg4JM
yzLgO20q9Yu6W+gwzkr9NZs4tlwdkYQxFo0ItveyJuJ5Biy+Ulxkd3BcK2F3p0/dsnpH31Ns
UmTm/AzVyvlThiBcpCheQXgFOF1ZGIVJcRRrHYgwIXoDxvBm9/C+fzr+9s3ZQiSMGzZIWthr
xIPSbIvy11YoVAFyQ+0aVFdcEQO7J4a0KAylhCiPLT7P1Ih4TCFHLK1OkXxQemEZJiQLjDVH
SRh79eXLoCBjS4dw62T/++34Onl43e/GJKlGOLUgxvfiI/O+kwWe+XAWpSTQJ43zdZLVK1M1
czF+IRVb4QN9Um6dDQYYSTj4M1xcjaFENJTofLDZUair3Mycp2Dqfd4Q3K9dhAs+09R9mjXy
cR203nhFl4vp7KLocg9RdjkN9D9fi79eAzDm6bpjHfMKiD8+mxQBeNS1K1hmVjCOxATUPl0O
+MjLOKz7nXc6lxOKHb0movfjzx1oqg/3x92PCXt5wDWCz5T8/+n4cxIdDq8PTwKV3h/vTdeU
7llCaQb6m0nhDVKyiuC/2Uld5dupTNJuEzTsOnMuVgg4g2Igpf2Y6lhcknh+/WHedNRfixN/
MlqfdxKCU1gSe7CcbwhuID5yO1ppV/eHn6HmyeuNzuIuIqI+/IjPDzdF5F9MSJ8e4dDhf4wn
81lCjKxEyGs24ckUVKHSMAg5LKoPS7fTkzRb+Iy5ktkHnEHV7OGNtkKIvfP81F9T6akvGVK/
HjjTrCK8L5b5M8CLFIQE0VdEkGnjRvzs7NyXeUU6N59+1Zy+iqYeLQL7pmnYnEJB7QpJVHY2
nYVLTvvCZ2dZIwWGujxwu+T4xKEL3tQUsZjWXnBFX2aSuYaN+Ontp32TSW+b/ioEmJ5qt8uI
Gqr2kGUXZ0R1PPErivNqs8iIfVYjxiBMlyMGCtnGDxZAVLA8zyJf9ChEiKEHPHQXehvd3P45
5SxMinEATh4MA3dGyBoBN75Px1GOtHRYl0kQqMymTAmmANi8Z3DsD3RvQW/Q61V0F6VE15oo
byLyxW6bIMSJelOjRk2hPu0npuXyVyLjNSt9LU3BYbmz4Bxrmg84xiAJVtMyX2FrN5VYL+44
KLgXs+ygQ1+y0P18Y8bUODRWp4b4mv3ucADlxRMsoOyih8RrrwqEd/b4u8ojvDidEXOb330w
n4BcDUkf+f3Lj9fnSfn+/H23nyx3L7v9/ZFqKSa8gAMjN5PR6U7wGK1BZecvB8QotcFto8RF
ZDCWSZK0vs6ICA/4LcP0mHgiRtMXpZn3kf3ClYP6pDUDWaOPEO5ADBTUKA1I8mAmNiXlsHfb
t6JiNaJmW2ASZGlrk7aH3wSy7uJc0TRdbJMZODhFOkeg27OTyz5hHF2AGL7VC1+oeW9mnTRf
h3g0Givtp2aaRgxKZ5haUV7TumFc1i89lXLB7PZHvJUK6v1BJMY5PD2+3B/f9yo8zbJay2sc
plGAW64jH98Y53Bh8lrfFIa1+6bwbkKpcJ/sznsWZX1DnTLirIy4MiYudK/yp+/7+/3vyf71
/fj0YurccdZyhpk4LH/vaBcd8ZRhXbTJfPlVO8ualpdJve0XvCqce2wmSc7KALZkbd+1mem9
0ii8AIgmY7QpZ62Px3cws8q6r6hRQbDBvthrvMqSFPVtspJxDZwtHAp0IS9QXxBpP+s8s0+X
CZwBQSSYCzGZntvSMuml8k+uemhU2/V2BXNLocQDBmVpUxhYXCze0snkLRJaWguCiG9k0kGn
ZBy4Gw9YKhof9hN1zLL7Tzcu6lK08uEgy7Wgp4lkwDKtCnsgFAo2J3kBzEq/i1A0I7tw3PNQ
BOayvyZUb5MDFLbCsWYLatRswGHHI1oCcLslo6n0DhHk2EhUHyffSKusrq1f3mWWm2BA5Hdm
TiLOMAKryitL4zWhWHZqnIViM7ttLKaobAwjs8KgA75hOIcUrF+bxjQDHhckeNEYcMtvZ+46
TZVkII+E4OKRFYiA143kdWgLhB6G3hIIIjDEHCG0UnP76vO1Ie7KXN3YckXD4B/E6coW4koP
ts2oOb/DvDcGoOJpZud1Sil3dlFnloKGN8A5W2aNtMaP5mQMIcpJn9/QTKARBiSiBzUMWG/Z
fAeUyIykHTz/Atgr8mAmVQEA

--BXVAT5kNtrzKuDFl--
