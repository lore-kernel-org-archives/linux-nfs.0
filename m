Received: from mail-ed1-f50.google.com (mail-ed1-f50.google.com [209.85.208.50])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C02DD3C2790
	for <linux-nfs@vger.kernel.org>; Sat, 22 Aug 2026 14:42:00 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.208.50
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787409722; cv=none; b=WuQmNFr0iBfl49VJocEUrqiihf60SxwUWKMLuKytunlYpZtlQQZv0Tx69efHOZ0S1zJdJ9A97+K0uBx3JMoBFGOeZZqAAiDELJqqufT84TFtv99MvLLkGXOK8L2jGNLLS2mi1aGw05QLHTBrg4gqWyet8HWX2SbALXgi5g+aq9s=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787409722; c=relaxed/simple;
	bh=E2iDaTg/q8KMhiM0Xc5lAgb2EaRXWrIYIzfFGLLz/KI=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=MBYd8wDbeIB3bjOPokpdJBZ5UY7XJx+qrwcerGPohbmzY/YIpaipQFPFlPLGBSp9ibFk11zLowv7Q6HjylpjaVsdR2LCIRBWKwcYJuQHAjsUkfdjphDSp95P+gfOucaatJRez7tEQadPUsgVoRDT2o1s86e2gg18Yy8tVgxBeCA=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=fail (p=none dis=none) header.from=debian.org; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=Ed5t4O1J; arc=none smtp.client-ip=209.85.208.50
Authentication-Results: smtp.subspace.kernel.org; dmarc=fail (p=none dis=none) header.from=debian.org
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="Ed5t4O1J"
Received: by mail-ed1-f50.google.com with SMTP id 4fb4d7f45d1cf-6a1542cdb53so2492337a12.2
        for <linux-nfs@vger.kernel.org>; Sat, 22 Aug 2026 07:42:00 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20251104; t=1787409719; x=1788014519; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:sender:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=6+sqRCfP2MTAmdJ3xOH+MaUsKYTlVfDopUh/thAnm8E=;
        b=Ed5t4O1J+uw6LfpjQiFiy2rzKm+Up169QbZhEy3eWuqxLkdkALuBpRAozA8BAi1Bey
         TQL91sVbN/aswRQy8RkB6Hj7jj3SLdDIdNlQHQlwEyohb89mZy5+3c8NJii1aJVNHHq/
         2g1VyqnSGg4uRuI4lm8Q8ETzjDv/fpoRqbq/rGS/GXUR91nwHom/IVYCdRKXsaUK04hL
         Z0I2/8sinvEqi1n/Fyq9WHzOXimBoeOjhkSfZ4MMdvKD9oAUwgQ0YoRlsBKYWHW1l3SF
         dWUZHg0r8WCXpjUlRC4vd/TloHN/IquEJnsARsa7m7iiGYQHvzKig1dvi5ZfsIUOx4Nw
         yvww==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1787409719; x=1788014519;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:sender:x-gm-gg:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=6+sqRCfP2MTAmdJ3xOH+MaUsKYTlVfDopUh/thAnm8E=;
        b=DIEdbL9BCttJN4xUaGYK3aHoUiFlie8frUwj5hY8++aXvxZhM39Xgm2L3xA0bZgeQj
         hsrPr12jo5aMYg6D6kOdmLQlTfA9//gRefFi4hgGEZZ9TcGwbXjHUVqgGEVynGguY+kw
         Kb6vgMyAtf+w8Bgi+kxy7Q3deEdzWZd20hHyNlA6jYX1gDSaJKarPJ9bzJljTYB+Cyn8
         3F8FF271zhbaNWtRKORFJkZ45atBO2loCzOYdVuPNgi3qzqZLwnhIVHe9f9244fnJkvX
         1aCLk/IviFxmfLJUy7eoPf1eKZKWQAUPQcEvciZBCLlZlBAX4K8E+xmmfyRtudMZ5LH/
         OCkQ==
X-Gm-Message-State: AFuF++nvG+hCYFAxhUv/2DLjr1cPDXssmXjVA00ydcQ+Qtumq1NzHJOW
	l9+OBPoqeUt0as+SV+l/U7mg6X5QKYqIOh5qPJ+dTvZmFMgsP6I+kChU
X-Gm-Gg: AR+sD12iBKSP7um8zoBkSmjTF1VBxg/VKWwiipD+86T/u4jUzFuVblmMeYGOFoh1VGF
	+4GCt4XXIbuZwv3fsslCRouZ3i1eV4ZPBQKgTalFRL0+cvp12KUEd4R3RhJ3SM7Zs2/MrVKs0Qf
	mcAme81lzIX1NCOlqCVK3WRa2zkwV1PWd5Sz6wyDYScV85T+zPWWGO5dvXFwncDrUX+IC/n79FQ
	ioKHA48xYz/XFNdEvQtoJrKptCP9kkccbNz5c6AVXYYHUFInaUmYVlISoC3ZLu/yjrylVNz5qHC
	NJ28ENCEx+poJgcY4GFZBFWFf40vEJrIRmOa24tuDJwJ6IE7UVknd90pBs9zAz26iGHd8VgE9Ok
	wnryFQRjNyX5fGFvdtLC2mql8qtB7009aDoQSimBvsCs7yZumkc7EBkL/MEDoxz7/VS741olmgK
	dU+Bf9T6ByuLHAGeIk5niFj4e/qB1ohJ96PcY0oRYbtk8S+ZM0lnKqHLeKrsLban+UPrdIGNCrD
	RpgNdbSJunEIAt22/o6DP4=
X-Received: by 2002:a05:6402:24d2:b0:6a1:8d1a:816b with SMTP id 4fb4d7f45d1cf-6a582b608a5mr6195237a12.11.1787409718779;
        Sat, 22 Aug 2026 07:41:58 -0700 (PDT)
Received: from eldamar.lan (c-82-192-247-196.customer.ggaweb.ch. [82.192.247.196])
        by smtp.gmail.com with ESMTPSA id 4fb4d7f45d1cf-6a3ff16c3bbsm13270033a12.24.2026.08.22.07.41.57
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Sat, 22 Aug 2026 07:41:57 -0700 (PDT)
Sender: Salvatore Bonaccorso <salvatore.bonaccorso@gmail.com>
Received: by eldamar.lan (Postfix, from userid 1000)
	id 65622BE2DE0; Sat, 22 Aug 2026 16:41:56 +0200 (CEST)
From: Salvatore Bonaccorso <carnil@debian.org>
To: Anna Schumaker <Anna.Schumaker@Netapp.com>,
	Steve Dickson <steved@redhat.com>
Cc: linux-nfs@vger.kernel.org,
	1144982@bugs.debian.org,
	Salvatore Bonaccorso <carnil@debian.org>,
	"Trent W. Buck" <trentbuck@gmail.com>
Subject: [PATCH] rpcctl: SyntaxWarning: 'return' in a 'finally' block
Date: Sat, 22 Aug 2026 16:41:42 +0200
Message-ID: <20260822144142.682662-1-carnil@debian.org>
X-Mailer: git-send-email 2.55.0
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

Trent W. Buck reported that when using rpcctl with Python 3.14
version, a SyntaxWarning warning is issued on the use of return in the
finally block in the read_info_file function.

Replace the finally clause with an except BaseException, and dedent the
return by one level up.

Reported-by: "Trent W. Buck" <trentbuck@gmail.com>
Link: https://docs.python.org/3/whatsnew/3.14.html#pep-765-control-flow-in-finally-blocks
Closes: https://bugs.debian.org/1144982
Signed-off-by: Salvatore Bonaccorso <carnil@debian.org>
---
 tools/rpcctl/rpcctl.py | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/tools/rpcctl/rpcctl.py b/tools/rpcctl/rpcctl.py
index 29ae7d26f50e..42e238ca1c52 100755
--- a/tools/rpcctl/rpcctl.py
+++ b/tools/rpcctl/rpcctl.py
@@ -43,8 +43,9 @@ def read_info_file(path):
         with open(path) as info:
             lines = [line.split("=", 1) for line in info if "=" in line]
             res.update({key: int(val.strip()) for (key, val) in lines})
-    finally:
-        return res
+    except BaseException:
+        pass
+    return res
 
 
 class Xprt:
-- 
2.55.0

